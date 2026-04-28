from datetime import datetime

def transform_data(data):
    try:
        return {
            "asset": "bitcoin",
            "price_gbp": data["bitcoin"]["gbp"],
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise ValueError(f"Data transformation failed: {e}")