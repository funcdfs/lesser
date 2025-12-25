FROM python:3.14-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install uv gunicorn

COPY pyproject.toml uv.lock ./
RUN uv pip install --system -e .

COPY . .