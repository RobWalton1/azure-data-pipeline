import unittest
from unittest.mock import Mock, patch

import requests

from src import api


class FetchDataTests(unittest.TestCase):
    @patch.object(api, "API_URL", "https://example.test/price")
    @patch("src.api.requests.get")
    def test_fetch_data_returns_json_response(self, mock_get):
        response = Mock()
        response.json.return_value = {"bitcoin": {"gbp": 52000}}
        mock_get.return_value = response

        result = api.fetch_data()

        self.assertEqual(result, {"bitcoin": {"gbp": 52000}})
        mock_get.assert_called_once_with("https://example.test/price")
        response.raise_for_status.assert_called_once_with()

    @patch.object(api, "API_URL", None)
    def test_fetch_data_requires_api_url(self):
        with self.assertRaisesRegex(ValueError, "API_URL is not set"):
            api.fetch_data()

    @patch.object(api, "API_URL", "https://example.test/price")
    @patch("src.api.requests.get")
    def test_fetch_data_raises_on_http_error_status(self, mock_get):
        response = Mock()
        response.raise_for_status.side_effect = requests.exceptions.HTTPError(
            "500 Server Error"
        )
        mock_get.return_value = response

        with self.assertRaises(requests.exceptions.HTTPError):
            api.fetch_data()

    @patch.object(api, "API_URL", "https://example.test/price")
    @patch("src.api.requests.get")
    def test_fetch_data_raises_on_connection_error(self, mock_get):
        mock_get.side_effect = requests.exceptions.ConnectionError("network down")

        with self.assertRaises(requests.exceptions.ConnectionError):
            api.fetch_data()

    @patch.object(api, "API_URL", "https://example.test/price")
    @patch("src.api.requests.get")
    def test_fetch_data_raises_on_invalid_json(self, mock_get):
        response = Mock()
        response.json.side_effect = ValueError("not json")
        mock_get.return_value = response

        with self.assertRaises(ValueError):
            api.fetch_data()
