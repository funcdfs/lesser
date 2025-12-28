"""
Management command to create superuser using PostgreSQL credentials from environment.
This ensures the superuser uses the same credentials as the database for consistency.
"""
import os
from django.core.management.base import BaseCommand
from apps.users.models import User


class Command(BaseCommand):
    help = 'Create superuser using PostgreSQL user and password from environment variables'

    def add_arguments(self, parser):
        parser.add_argument(
            '--email',
            type=str,
            default='admin@lesser.local',
            help='Email for superuser (default: admin@lesser.local)',
        )
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force recreate superuser if exists',
        )

    def handle(self, *args, **options):
        # Get PostgreSQL credentials from environment
        pg_user = os.environ.get('POSTGRES_USER') or os.environ.get('DB_USER', 'lesser')
        pg_password = os.environ.get('POSTGRES_PASSWORD') or os.environ.get('DB_PASSWORD', 'lesser_dev_password')
        email = options['email']
        force = options['force']

        self.stdout.write(f'Creating superuser with PostgreSQL credentials...')
        self.stdout.write(f'  Username: {pg_user}')
        self.stdout.write(f'  Email: {email}')

        # Check if user exists
        existing_user = User.objects.filter(username=pg_user).first()
        if existing_user:
            if force:
                self.stdout.write(self.style.WARNING(f'Deleting existing user: {pg_user}'))
                existing_user.delete()
            else:
                self.stdout.write(self.style.WARNING(f'User {pg_user} already exists'))
                if not existing_user.is_superuser:
                    existing_user.is_superuser = True
                    existing_user.is_staff = True
                    existing_user.save()
                    self.stdout.write(self.style.SUCCESS(f'Updated {pg_user} to superuser'))
                return

        # Create superuser
        user = User.objects.create_superuser(
            email=email,
            username=pg_user,
            password=pg_password,
        )

        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS('=' * 50))
        self.stdout.write(self.style.SUCCESS('Superuser created successfully!'))
        self.stdout.write(self.style.SUCCESS('=' * 50))
        self.stdout.write(f'  ID: {user.id}')
        self.stdout.write(f'  Username: {user.username}')
        self.stdout.write(f'  Email: {user.email}')
        self.stdout.write(f'  Password: (same as POSTGRES_PASSWORD)')
        self.stdout.write('')
        self.stdout.write('Login at: http://localhost:8000/admin/')
        self.stdout.write('')
