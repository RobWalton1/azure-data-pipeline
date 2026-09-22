import unittest
from datetime import datetime

from src.transform import transform_data


class TransformDataTests(unittest.TestCase):
    def test_transform_data_returns_expected_schema(self):
        result = transform_data({"bitcoin": {"gbp": 52000}})

        self.assertEqual(result["asset"], "bitcoin")
        self.assertEqual(result["price_gbp"], 52000)
        datetime.fromisoformat(result["timestamp"])

    def test_transform_data_raises_value_error_for_missing_price(self):
        with self.assertRaisesRegex(ValueError, "Data transformation failed"):
            transform_data({"bitcoin": {}})

    def test_transform_data_raises_value_error_for_missing_asset(self):
        with self.assertRaisesRegex(ValueError, "Data transformation failed"):
            transform_data({})

    def test_transform_data_raises_value_error_for_non_dict_input(self):
        with self.assertRaisesRegex(ValueError, "Data transformation failed"):
            transform_data(None)

    def test_transform_data_preserves_zero_price(self):
        result = transform_data({"bitcoin": {"gbp": 0}})

        self.assertEqual(result["price_gbp"], 0)
