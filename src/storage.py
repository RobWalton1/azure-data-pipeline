import json
import logging
import os

from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Environment variables
ACCOUNT_URL = os.getenv("AZURE_STORAGE_ACCOUNT_URL")
CONTAINER_NAME = os.getenv("BLOB_CONTAINER_NAME")


def save_to_blob(data, blob_name="output.json"):
    try:
        logging.info("Uploading data to Azure Blob Storage...")

        if not ACCOUNT_URL:
            raise ValueError("Azure storage account URL is missing")

        # Managed identity in Azure; falls back to `az login` locally.
        blob_service_client = BlobServiceClient(
            account_url=ACCOUNT_URL,
            credential=DefaultAzureCredential()
        )

        # Get blob client
        blob_client = blob_service_client.get_blob_client(
            container=CONTAINER_NAME,
            blob=blob_name
        )

        # Convert data to JSON
        json_data = json.dumps(data, indent=4)

        # Upload blob
        blob_client.upload_blob(json_data, overwrite=True)

        logging.info(f"Successfully uploaded {blob_name}")

    except Exception as e:
        logging.error(f"Failed to upload blob: {e}")
        raise
