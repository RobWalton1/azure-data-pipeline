import unittest
from unittest.mock import patch

from src import main


class PipelineMainTests(unittest.TestCase):
    @patch("src.main.save_to_blob")
    @patch("src.main.transform_data")
    @patch("src.main.fetch_data")
    def test_main_runs_pipeline_in_order(self, mock_fetch, mock_transform, mock_save):
        raw_data = {"bitcoin": {"gbp": 52000}}
        transformed_data = {"asset": "bitcoin", "price_gbp": 52000}
        mock_fetch.return_value = raw_data
        mock_transform.return_value = transformed_data

        main.main()

        mock_fetch.assert_called_once_with()
        mock_transform.assert_called_once_with(raw_data)
        mock_save.assert_called_once_with(transformed_data)

    @patch("src.main.save_to_blob")
    @patch("src.main.transform_data")
    @patch("src.main.fetch_data")
    def test_main_reraises_and_does_not_save_on_fetch_failure(
        self, mock_fetch, mock_transform, mock_save
    ):
        mock_fetch.side_effect = RuntimeError("api unreachable")

        with self.assertRaisesRegex(RuntimeError, "api unreachable"):
            main.main()

        mock_transform.assert_not_called()
        mock_save.assert_not_called()

    @patch("src.main.save_to_blob")
    @patch("src.main.transform_data")
    @patch("src.main.fetch_data")
    def test_main_reraises_on_save_failure(self, mock_fetch, mock_transform, mock_save):
        mock_fetch.return_value = {"bitcoin": {"gbp": 52000}}
        mock_transform.return_value = {"asset": "bitcoin", "price_gbp": 52000}
        mock_save.side_effect = RuntimeError("upload failed")

        with self.assertRaisesRegex(RuntimeError, "upload failed"):
            main.main()
