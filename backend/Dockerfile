FROM python:3.11-slim

# Install system dependencies (optional but good for FastAPI extensions like databases)
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Set workdir inside container
WORKDIR /app

# Install pipenv
RUN pip install pipenv

# Copy Pipfile and Pipfile.lock (separate step for better cache)
COPY Pipfile ./

# Install project dependencies
RUN pipenv install --dev

# Copy application code
COPY app/ ./app/

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose FastAPI port
EXPOSE 8000

# Default command
CMD ["/entrypoint.sh", "start"]