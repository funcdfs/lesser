"""
Management command to setup test users for chat demo.
Creates test1 and test2 users with mutual follow relationships (friends).
"""
from django.core.management.base import BaseCommand
from apps.users.models import User, Follow


class Command(BaseCommand):
    help = 'Setup mock users and data'

    def add_arguments(self, parser):
        parser.add_argument(
            '--password',
            type=str,
            default='testtesttest',
            help='Password for test users (default: testtesttest)',
        )
        parser.add_argument(
            '--clean',
            action='store_true',
            help='Delete existing test users before creating new ones',
        )

    def handle(self, *args, **options):
        password = options['password']
        clean = options['clean']

        if clean:
            self.stdout.write('Cleaning existing test users...')
            User.objects.filter(username__in=['test1', 'test2']).delete()

        # Create test1
        test1, created1 = User.objects.get_or_create(
            username='test1',
            defaults={
                'email': 'test1@example.com',
                'display_name': 'Test User 1',
            }
        )
        if created1:
            test1.set_password(password)
            test1.save()
            self.stdout.write(self.style.SUCCESS(f'Created user: test1 (id: {test1.id})'))
        else:
            self.stdout.write(f'User test1 already exists (id: {test1.id})')

        # Create test2
        test2, created2 = User.objects.get_or_create(
            username='test2',
            defaults={
                'email': 'test2@example.com',
                'display_name': 'Test User 2',
            }
        )
        if created2:
            test2.set_password(password)
            test2.save()
            self.stdout.write(self.style.SUCCESS(f'Created user: test2 (id: {test2.id})'))
        else:
            self.stdout.write(f'User test2 already exists (id: {test2.id})')

        # Create mutual follow relationships (friends)
        follow1, created_f1 = Follow.objects.get_or_create(
            follower=test1,
            following=test2
        )
        if created_f1:
            self.stdout.write(self.style.SUCCESS('Created follow: test1 -> test2'))
        else:
            self.stdout.write('Follow test1 -> test2 already exists')

        follow2, created_f2 = Follow.objects.get_or_create(
            follower=test2,
            following=test1
        )
        if created_f2:
            self.stdout.write(self.style.SUCCESS('Created follow: test2 -> test1'))
        else:
            self.stdout.write('Follow test2 -> test1 already exists')

        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS('=' * 50))
        self.stdout.write(self.style.SUCCESS('Test users setup complete!'))
        self.stdout.write(self.style.SUCCESS('=' * 50))
        self.stdout.write(f'  test1: {test1.email} (id: {test1.id})')
        self.stdout.write(f'  test2: {test2.email} (id: {test2.id})')
        self.stdout.write(f'  Password: {password}')
        self.stdout.write(f'  Relationship: Friends (mutual follow)')
        self.stdout.write('')
