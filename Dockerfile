# Use a lightweight Python base image
FROM python:3.12-slim

# Stream logs straight to stdout and skip writing .pyc files
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Set working directory inside container
WORKDIR /app

# Copy dependency file first (better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src ./src

# Run as an unprivileged user; numeric UID so runtimes can verify it is non-root
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin appuser
USER 10001

# Run the pipeline
CMD ["python", "-m", "src.main"]
