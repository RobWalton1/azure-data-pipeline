# 🚀 Azure Cloud Data Pipeline (Phase 1)

## 📌 Overview

This project is a modular Python-based data pipeline that ingests data from a public API, processes it, and stores the result locally.

It is designed as the foundation for a cloud-native pipeline that will later be deployed to Microsoft Azure using containerisation, CI/CD, secure secrets management, and monitoring.

---

## 🎯 Project Goals

* Build a structured data pipeline using Python
* Follow clean architecture principles
* Prepare for containerisation (Docker)
* Lay the groundwork for Azure deployment

---

## 🧱 Architecture

The pipeline follows a clear separation of concerns:

```
src/
 ├── main.py        # Orchestrates pipeline execution
 ├── api.py         # Fetches data from external API
 ├── transform.py   # Transforms raw data into structured format
 └── storage.py     # Saves processed data
```

---

## 🔄 Data Flow

1. Fetch data from external API (CoinGecko)
2. Transform raw JSON into structured format
3. Save output to a local file (`output.json`)
4. Log execution steps and errors

---

## ⚙️ How It Works

### 1. Data Ingestion (`api.py`)

* Calls the external API
* Handles request errors
* Returns raw JSON data

### 2. Transformation (`transform.py`)

* Extracts relevant fields (price, timestamp)
* Structures data into a consistent schema

### 3. Storage (`storage.py`)

* Saves processed data to `output.json`
* Includes logging and error handling

### 4. Orchestration (`main.py`)

* Coordinates the full pipeline
* Handles logging and failure states

---

## 📄 Example Output

```json
{
  "asset": "bitcoin",
  "price_gbp": 52000,
  "timestamp": "2026-04-28T23:02:10"
}
```

---

## 🛠️ Setup & Installation

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd azure-data-pipeline
```

### 2. Create and activate environment (Anaconda)

```bash
conda create -n azure python=3.12
conda activate azure
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

---

## 🔐 Environment Variables

Create a `.env` file in the root directory:

```
API_URL=https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=gbp
```

---

## ▶️ Running the Pipeline

Run the project using:

```bash
python -m src.main
```

---

## 📊 Logging

The pipeline includes structured logging to track:

* Execution start and completion
* API requests
* File storage operations
* Errors and failures

---

## 🧠 Key Concepts Demonstrated

* Modular Python architecture
* Separation of concerns
* API integration
* Data transformation
* Error handling and logging
* Environment variable management

---

## 🚀 Future Enhancements (Next Phases)

* 🐳 Docker containerisation
* ☁️ Deployment to Microsoft Azure
* 📦 Azure Blob Storage integration
* 🔐 Azure Key Vault for secrets
* 🔁 CI/CD with GitHub Actions
* 📊 Monitoring with Azure Monitor

---

## 🧾 CV Description

Designed and implemented a modular data pipeline in Python that ingests, processes, and stores external API data, forming the foundation for a cloud-native solution using Docker, Azure, CI/CD, and secure secret management.

---

## ⚠️ Notes

* This is Phase 1 of a larger cloud project
* Focus is on structure and scalability rather than complexity
* Designed to evolve into a production-ready system

---

## 👤 Author

Rob

---
