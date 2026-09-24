# Azure Cloud Data Pipeline

I designed and built this production-style cloud data pipeline to demonstrate modern cloud, DevOps, and infrastructure engineering practices using Microsoft Azure.

The Python application retrieves data from a public REST API, transforms it, and stores the resulting output in Azure Blob Storage. It is packaged as a Docker container, published to Azure Container Registry (ACR), and executed by an Azure Container Apps Job.

All Azure infrastructure is provisioned with Terraform. The configuration is organised into reusable modules for storage, ACR, the Container Apps environment, Container Apps Job, managed identity, and Log Analytics; Terraform state is held remotely in Azure Storage for reliable infrastructure management.

GitHub Actions automates delivery: a push to `main` builds the image, pushes it to ACR with a commit-SHA version tag, and updates the Container Apps Job to run that version. Azure Log Analytics provides centralised execution logs, with KQL available for querying logs and troubleshooting deployments.

## Key technologies

Python · Docker · Microsoft Azure · Terraform · GitHub Actions · Azure Container Registry · Azure Container Apps · Azure Blob Storage · Azure Log Analytics · KQL · Git · Linux

## Engineering practices demonstrated

- Infrastructure as Code using modular Terraform
- Remote Terraform state management
- Containerisation with Docker
- Automated CI/CD with GitHub Actions
- Versioned container deployments using Git commit SHA tags
- Secretless authentication with managed identity and least-privilege Azure RBAC
- Centralised logging and monitoring
- KQL-based troubleshooting
- Azure CLI and infrastructure troubleshooting
- Separation of application and infrastructure concerns

## What it does

Each execution performs the following work:

1. Reads the API endpoint from `API_URL`.
2. Retrieves the CoinGecko response.
3. Extracts the Bitcoin price in GBP and adds a UTC timestamp.
4. Serialises the result as JSON.
5. Uploads it to `output.json` in the configured Azure Blob Storage container.

Example blob content:

```json
{
  "asset": "bitcoin",
  "price_gbp": 52000,
  "timestamp": "2026-09-20T12:34:56.789012"
}
```

## Architecture

```text
Public REST API
       |
       v
Python pipeline (retrieve and transform)
       |
       v
Docker image --> Azure Container Registry --> Azure Container Apps Job --> Azure Blob Storage
                                                   |
                                                   v
                                      Azure Log Analytics / KQL

GitHub --> GitHub Actions --> Docker build --> ACR --> Container Apps Job update
```

The Python application is organised by responsibility:

| Path | Purpose |
| --- | --- |
| `src/main.py` | Runs the pipeline and configures logging. |
| `src/api.py` | Retrieves JSON data from the configured API. |
| `src/transform.py` | Converts the API response into the output schema. |
| `src/storage.py` | Uploads the transformed JSON to Azure Blob Storage. |
| `terraform/` | Defines Azure infrastructure as reusable Terraform modules. |
| `.github/workflows/deploy.yml` | Builds and publishes the image, then updates the Container Apps Job. |

## Prerequisites

For local execution, install:

- Python 3.12 or later
- An Azure Storage account and Blob container

For container and infrastructure deployment, also install:

- Docker
- Azure CLI authenticated to the target Azure subscription
- Terraform compatible with the AzureRM provider `~> 4.0`

## Local setup and execution

Clone the repository and create a virtual environment:

```bash
git clone <repository-url>
cd azure-data-pipeline
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Create a `.env` file in the repository root. It contains no secrets, but is ignored by Git.

```dotenv
API_URL=https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=gbp
AZURE_STORAGE_ACCOUNT_URL=https://<storage-account-name>.blob.core.windows.net/
BLOB_CONTAINER_NAME=pipeline-output
```

The configured container must already exist. The Terraform configuration creates `pipeline-output` by default.

The pipeline authenticates to Blob Storage with `DefaultAzureCredential`, so locally it uses your Azure CLI login. Sign in, and grant yourself data-plane access (subscription Owner alone does not include it):

```bash
az login
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee "$(az ad signed-in-user show --query id -o tsv)" \
  --scope "$(az storage account show --name <storage-account-name> --query id -o tsv)"
```

Run the pipeline:

```bash
python -m src.main
```

Successful execution logs the upload and overwrites `output.json` in the specified blob container.

## Run with Docker

Build the image:

```bash
docker build -t azure-data-pipeline .
```

Run it using the same environment variables. Your Azure CLI login is not available inside the container, so local container runs need a credential source that `DefaultAzureCredential` supports, such as a service principal passed via `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` and `AZURE_CLIENT_SECRET`:

```bash
docker run --rm --env-file .env azure-data-pipeline
```

## Provision Azure infrastructure

Terraform creates the following resources:

- Resource group
- Storage account and private `pipeline-output` Blob container
- Azure Container Registry (ACR)
- Log Analytics workspace
- Azure Container Apps environment
- User-assigned managed identity for the job, with `AcrPull` on the registry and `Storage Blob Data Contributor` on the storage account
- `AcrPush` on the registry for the CI service principal
- Manually triggered Azure Container Apps Job

The remote Terraform state backend is configured in `terraform/backend.tf`. Ensure the backend resource group, storage account, and `tfstate` container already exist and that your Azure identity can access them.

Create a local `terraform.tfvars` file inside `terraform/`. It contains no secrets, but is ignored by Git because it holds environment-specific values.

```hcl
resource_group_name        = "data-pipeline-rg"
location                   = "uksouth"
storage_account_name       = "<globally-unique-storage-account-name>"
acr_name                   = "<globally-unique-acr-name>"
container_env_name         = "data-pipeline-env"
container_job_name         = "data-pipeline-job"
log_analytics_name         = "data-pipeline-logs"
api_url                    = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=gbp"
blob_container_name        = "pipeline-output"
identity_name              = "data-pipeline-job-identity"
ci_principal_id            = "<object-id-of-the-github-actions-service-principal>"
```

Find `ci_principal_id` from the `clientId` in your `AZURE_CREDENTIALS` secret:

```bash
az ad sp show --id <clientId> --query id -o tsv
```

Applying the configuration requires permission to create role assignments (Owner or User Access Administrator on the resource group).

Then initialise and apply the configuration:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform creates the Container Apps Job with a public placeholder image, because a new registry is empty and the job cannot be created with an image that does not exist. The GitHub Actions workflow described below then deploys the real image; the job ignores image changes in Terraform, so later applies do not revert it. This means a new environment can be built from nothing with a single `terraform apply`.

## CI/CD

On every push to `main`, [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) does the following:

1. Runs the test suite.
2. Authenticates to Azure and logs in to ACR with the same identity (`az acr login`).
3. Builds the Docker image, tagged with the short commit SHA and `latest`.
4. Pushes both tags to Azure Container Registry.
5. Updates the Azure Container Apps Job to use the commit-SHA image.

Configure this repository secret before enabling the workflow:

| Secret | Description |
| --- | --- |
| `AZURE_CREDENTIALS` | Azure service-principal credentials accepted by `azure/login`. Terraform grants this principal every role the workflow needs, scoped to the registry, the job and the job's identity; it needs no broader access. |

The workflow currently names the target registry, job, and resource group directly. If you use different Azure resource names, update the `REGISTRY` value and the `az containerapp job update` command in the workflow.

## Configuration reference

| Variable | Required | Description |
| --- | --- | --- |
| `API_URL` | Yes | Endpoint returning CoinGecko-style JSON with `bitcoin.gbp`. |
| `AZURE_STORAGE_ACCOUNT_URL` | Yes | Blob endpoint of the destination storage account. |
| `AZURE_CLIENT_ID` | In Azure | Client ID of the user-assigned managed identity. Set by Terraform; tells `DefaultAzureCredential` which identity to use. |
| `BLOB_CONTAINER_NAME` | Yes | Destination Blob container name. |

## Operational notes

- The pipeline writes to a fixed blob name, `output.json`; each run replaces the previous output.
- Timestamps are generated in UTC.
- The Container Apps Job uses a manual trigger configuration with one replica and a 300-second timeout.
- Application logs are written to standard output and are available through the Container Apps environment's Log Analytics workspace when run in Azure.

## Security

The running pipeline holds no secrets. Each actor has its own Azure AD identity, scoped to the minimum role it needs:

| Actor | Identity | Roles |
| --- | --- | --- |
| Container Apps Job | User-assigned managed identity | `AcrPull` on the registry, `Storage Blob Data Contributor` on the storage account |
| GitHub Actions | Service principal | `AcrPush` on the registry, `Contributor` on the job only, `Managed Identity Operator` on the job's identity |
| Local development | Developer's Azure CLI login | `Storage Blob Data Contributor`, granted manually |

The ACR admin account is disabled, and no storage connection string or account key is distributed.

A user-assigned identity is used rather than a system-assigned one because the job pulls its image on creation. A system-assigned identity would not exist until the job did, so it could not be granted `AcrPull` in advance.

Known remaining gap: `AZURE_CREDENTIALS` is a long-lived service-principal secret. Replacing it with GitHub OIDC workload identity federation would remove the last stored credential.

## License

No license is currently specified for this repository.
