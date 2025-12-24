# Lesser Backend (Django)

Modern Django backend for the Lesser social platform.

## Technology Stack
- **Framework**: Django 5.x
- **API**: Django Ninja (Fast, Type-safe Async API)
- **Environment**: django-environ
- **Linter/Formatter**: Ruff
- **Database**: SQLite (Development), PostgreSQL (Production ready)

## Setup Instructions

1. **Create Virtual Environment**:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure Environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your local settings
   ```

4. **Initialize Database**:
   ```bash
   python manage.py migrate
   ```

5. **Run Development Server**:
   ```bash
   python manage.py runserver
   ```

## API Documentation
Once the server is running, visit:
- **Swagger UI**: http://127.0.0.1:8000/api/docs
- **Redoc**: http://127.0.0.1:8000/api/redoc

## Development Tools
- **Linting/Formatting**: `ruff check .` and `ruff format .`
- **Health Check**: `curl http://127.0.0.1:8000/api/health`
