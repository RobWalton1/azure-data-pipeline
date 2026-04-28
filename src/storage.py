import json
import logging

def save_to_file(data, filename="output.json"):
    try:
        logging.info("Saving data to file...")

        with open(filename, "w") as f:
            json.dump(data, f, indent=4)

    except Exception as e:
        logging.error(f"Failed to save file: {e}")
        raise