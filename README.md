# Azure Cloud Data Pipeline

I designed and built this production-style cloud data pipeline to demonstrate modern cloud, DevOps, and infrastructure engineering practices using Microsoft Azure.

The Python application retrieves data from a public REST API, transforms it, and stores the resulting output in Azure Blob Storage. It is packaged as a Docker container, published to Azure Container Registry (ACR), and executed by an Azure Container Apps Job.

All Azure infrastructure is provisioned with Terraform. The configuration is organised into reusable modules for storage, ACR, the Container Apps environment, Container Apps Job, and Log Analytics; Terraform state is held remotely in Azure Storage for reliable infrastructure management.

GitHub Actions automates delivery: a push to `main` builds the image, pushes it to ACR with a commit-SHA version tag, and updates the Container Apps Job to run that version. Azure Log Analytics provides centralised execution logs, with KQL available for querying logs and troubleshooting deployments.

## Key technologies

Python · Docker · Microsoft Azure · Terraform · GitHub Actions · Azure Container Registry · Azure Container Apps · Azure Blob Storage · Azure Log Analytics · KQL · Git · Linux

## Engineering practices demonstrated

- Infrastructure as Code using modular Terraform
- Remote Terraform state management
- Containerisation with Docker
- Automated CI/CD with GitHub Actions
- Versioned container deployments using Git commit SHA tags
- Cloud secrets and environment configuration
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

Create a `.env` file in the repository root. It is ignored by Git and must not be committed.

```dotenv
API_URL=https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=gbp
AZURE_STORAGE_CONNECTION_STRING=<storage-account-connection-string>
BLOB_CONTAINER_NAME=pipeline-output
```

The configured container must already exist. The Terraform configuration creates `pipeline-output` by default.

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

Run it using the same environment variables:

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
- Manually triggered Azure Container Apps Job

The remote Terraform state backend is configured in `terraform/backend.tf`. Ensure the backend resource group, storage account, and `tfstate` container already exist and that your Azure identity can access them.

Create a local `terraform.tfvars` file inside `terraform/`; it is ignored by Git because it includes secrets.

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
storage_connection_string  = "<storage-account-connection-string>"
```

Then initialise and apply the configuration:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform sets the Container Apps Job image to `data-pipeline:latest` in the ACR. Push an image with that tag, or use the GitHub Actions workflow described below, before running the job.

## CI/CD

On every push to `main`, [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) does the following:

1. Builds the Docker image.
2. Tags it with the short commit SHA and `latest`.
3. Pushes both tags to Azure Container Registry.
4. Authenticates to Azure.
5. Updates the Azure Container Apps Job to use the commit-SHA image.

Configure these repository secrets before enabling the workflow:

| Secret | Description |
| --- | --- |
| `AZURE_REGISTRY_LOGIN_SERVER` | ACR login server, for example `example.azurecr.io`. |
| `AZURE_REGISTRY_USERNAME` | ACR admin username. |
| `AZURE_REGISTRY_PASSWORD` | ACR admin password. |
| `AZURE_CREDENTIALS` | Azure service-principal credentials accepted by `azure/login`. |

The workflow currently names the target registry, job, and resource group directly. If you use different Azure resource names, update the `REGISTRY` value and the `az containerapp job update` command in the workflow.

## Configuration reference

| Variable | Required | Description |
| --- | --- | --- |
| `API_URL` | Yes | Endpoint returning CoinGecko-style JSON with `bitcoin.gbp`. |
| `AZURE_STORAGE_CONNECTION_STRING` | Yes | Connection string for the destination storage account. |
| `BLOB_CONTAINER_NAME` | Yes | Destination Blob container name. |

## Operational notes

- The pipeline writes to a fixed blob name, `output.json`; each run replaces the previous output.
- Timestamps are generated in UTC.
- The Container Apps Job uses a manual trigger configuration with one replica and a 300-second timeout.
- Application logs are written to standard output and are available through the Container Apps environment's Log Analytics workspace when run in Azure.

## Security

Keep `.env` and `terraform.tfvars` local. They can contain storage connection strings and other credentials. For production use, prefer managed identities and a secrets-management service over distributing connection strings.

## License

No license is currently specified for this repository.
