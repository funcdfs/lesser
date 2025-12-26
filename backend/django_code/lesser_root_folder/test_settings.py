"""
Test settings for Django tests.

Uses SQLite in-memory database for faster tests without requiring PostgreSQL.
"""
from .settings import *

# Override database to use SQLite for tests
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}

# Disable debug toolbar for tests
INSTALLED_APPS = [app for app in INSTALLED_APPS if app != 'debug_toolbar']
MIDDLEWARE = [m for m in MIDDLEWARE if 'debug_toolbar' not in m]

# Use a simplified URL configuration for tests
ROOT_URLCONF = 'lesser_root_folder.test_urls'

# Speed up password hashing for tests
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.MD5PasswordHasher',
]
