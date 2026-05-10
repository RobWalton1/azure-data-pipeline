import logging
from src.api import fetch_data
from src.transform import transform_data
from src.storage import save_to_blob

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def main():
    logging.info("Pipeline started")

    try:
        raw_data = fetch_data()
        transformed_data = transform_data(raw_data)
        save_to_blob(transformed_data)

        logging.info("Pipeline completed successfully, CI/CD is implemented")

    except Exception as e:
        logging.error(f"Pipeline failed: {e}")
        raise

if __name__ == "__main__":
    main()