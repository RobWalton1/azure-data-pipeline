import json
import unittest
from unittest.mock import Mock, patch

from src import storage

ACCOUNT_URL = "https://example.blob.core.windows.net/"


@patch.object(storage, "CONTAINER_NAME", "pipeline-output")
@patch.object(storage, "ACCOUNT_URL", ACCOUNT_URL)
@patch("src.storage.DefaultAzureCredential")
@patch("src.storage.BlobServiceClient")
class SaveToBlobTests(unittest.TestCase):
    def _service_client(self, mock_blob_service_client):
        blob_client = Mock()
        service_client = Mock()
        service_client.get_blob_client.return_value = blob_client
        mock_blob_service_client.return_value = service_client
        return service_client, blob_client

    def test_save_to_blob_serializes_and_uploads_data(
        self, mock_blob_service_client, mock_credential
    ):
        service_client, blob_client = self._service_client(mock_blob_service_client)
        data = {"asset": "bitcoin", "price_gbp": 52000}

        storage.save_to_blob(data, blob_name="prices.json")

        service_client.get_blob_client.assert_called_once_with(
            container="pipeline-output", blob="prices.json"
        )
        uploaded_data = blob_client.upload_blob.call_args.args[0]
        self.assertEqual(json.loads(uploaded_data), data)
        blob_client.upload_blob.assert_called_once_with(uploaded_data, overwrite=True)

    def test_save_to_blob_authenticates_with_default_azure_credential(
        self, mock_blob_service_client, mock_credential
    ):
        self._service_client(mock_blob_service_client)

        storage.save_to_blob({"asset": "bitcoin"})

        mock_blob_service_client.assert_called_once_with(
            account_url=ACCOUNT_URL, credential=mock_credential.return_value
        )

    def test_save_to_blob_defaults_blob_name_to_output_json(
        self, mock_blob_service_client, mock_credential
    ):
        service_client, _ = self._service_client(mock_blob_service_client)

        storage.save_to_blob({"asset": "bitcoin"})

        service_client.get_blob_client.assert_called_once_with(
            container="pipeline-output", blob="output.json"
        )

    def test_save_to_blob_propagates_upload_failure(
        self, mock_blob_service_client, mock_credential
    ):
        _, blob_client = self._service_client(mock_blob_service_client)
        blob_client.upload_blob.side_effect = RuntimeError("upload failed")

        with self.assertRaisesRegex(RuntimeError, "upload failed"):
            storage.save_to_blob({"asset": "bitcoin"})

    def test_save_to_blob_requires_account_url(
        self, mock_blob_service_client, mock_credential
    ):
        with patch.object(storage, "ACCOUNT_URL", None):
            with self.assertRaisesRegex(ValueError, "account URL is missing"):
                storage.save_to_blob({"asset": "bitcoin"})

        mock_blob_service_client.assert_not_called()
