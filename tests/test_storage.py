import json
import unittest
from unittest.mock import Mock, patch

from src import storage


class SaveToBlobTests(unittest.TestCase):
    @patch.object(storage, "CONTAINER_NAME", "pipeline-output")
    @patch.object(storage, "CONNECTION_STRING", "UseDevelopmentStorage=true")
    @patch("src.storage.BlobServiceClient.from_connection_string")
    def test_save_to_blob_serializes_and_uploads_data(self, mock_from_connection_string):
        blob_client = Mock()
        service_client = Mock()
        service_client.get_blob_client.return_value = blob_client
        mock_from_connection_string.return_value = service_client
        data = {"asset": "bitcoin", "price_gbp": 52000}

        storage.save_to_blob(data, blob_name="prices.json")

        mock_from_connection_string.assert_called_once_with("UseDevelopmentStorage=true")
        service_client.get_blob_client.assert_called_once_with(
            container="pipeline-output", blob="prices.json"
        )
        uploaded_data = blob_client.upload_blob.call_args.args[0]
        self.assertEqual(json.loads(uploaded_data), data)
        blob_client.upload_blob.assert_called_once_with(uploaded_data, overwrite=True)

    @patch.object(storage, "CONNECTION_STRING", None)
    def test_save_to_blob_requires_connection_string(self):
        with self.assertRaisesRegex(ValueError, "connection string is missing"):
            storage.save_to_blob({"asset": "bitcoin"})

    @patch.object(storage, "CONTAINER_NAME", "pipeline-output")
    @patch.object(storage, "CONNECTION_STRING", "UseDevelopmentStorage=true")
    @patch("src.storage.BlobServiceClient.from_connection_string")
    def test_save_to_blob_defaults_blob_name_to_output_json(self, mock_from_connection_string):
        blob_client = Mock()
        service_client = Mock()
        service_client.get_blob_client.return_value = blob_client
        mock_from_connection_string.return_value = service_client

        storage.save_to_blob({"asset": "bitcoin"})

        service_client.get_blob_client.assert_called_once_with(
            container="pipeline-output", blob="output.json"
        )

    @patch.object(storage, "CONTAINER_NAME", "pipeline-output")
    @patch.object(storage, "CONNECTION_STRING", "UseDevelopmentStorage=true")
    @patch("src.storage.BlobServiceClient.from_connection_string")
    def test_save_to_blob_propagates_upload_failure(self, mock_from_connection_string):
        blob_client = Mock()
        blob_client.upload_blob.side_effect = RuntimeError("upload failed")
        service_client = Mock()
        service_client.get_blob_client.return_value = blob_client
        mock_from_connection_string.return_value = service_client

        with self.assertRaisesRegex(RuntimeError, "upload failed"):
            storage.save_to_blob({"asset": "bitcoin"})
