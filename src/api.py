import requests
import logging
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

API_URL = os.getenv("API_URL")

def fetch_data():
    try:
        logging.info("Fetching data from API...")

        if not API_URL:
            raise ValueError("API_URL is not set in environment variables")

        response = requests.get(API_URL)
        response.raise_for_status()

        return response.json()

    except Exception as e:
        logging.error(f"API request failed: {e}")
        raise

print("fetch_data exists:", callable(fetch_data))