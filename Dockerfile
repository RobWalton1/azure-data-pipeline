# Use a lightweight Python base image
FROM python:3.12-slim

# Set working directory inside container
WORKDIR /app

# Copy dependency file first (better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src ./src

# Run the pipeline
CMD ["python", "-m", "src.main"]