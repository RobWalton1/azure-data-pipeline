import json
import logging
import os

from azure.storage.blob import BlobServiceClient
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Environment variables
CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
CONTAINER_NAME = os.getenv("BLOB_CONTAINER_NAME")


def save_to_blob(data, blob_name="output.json"):
    try:
        logging.info("Uploading data to Azure Blob Storage...")

        if not CONNECTION_STRING:
            raise ValueError("Azure storage connection string is missing")

        # Create blob service client
        blob_service_client = BlobServiceClient.from_connection_string(
            CONNECTION_STRING
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