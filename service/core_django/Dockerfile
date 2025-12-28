# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install UV for fast package management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy and install dependencies using UV
COPY requirements.txt ./
RUN uv pip install --system --no-cache -r requirements.txt

# Expose ports
EXPOSE 8000 50051

# Default command for development (hot reload)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
