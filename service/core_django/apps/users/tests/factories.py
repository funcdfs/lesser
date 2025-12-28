"""
Factory classes for User models.
"""
import factory
from factory.django import DjangoModelFactory

from apps.users.models import Follow, User


class UserFactory(DjangoModelFactory):
    """Factory for creating User instances."""

    class Meta:
        model = User

    username = factory.Sequence(lambda n: f'user{n}')
    email = factory.LazyAttribute(lambda obj: f'{obj.username}@example.com')
    display_name = factory.Faker('name')
    bio = factory.Faker('sentence')
    is_active = True
    is_verified = False

    @factory.post_generation
    def password(self, create, extracted, **kwargs):
        password = extracted or 'TestPass123!'
        self.set_password(password)
        if create:
            self.save()


class FollowFactory(DjangoModelFactory):
    """Factory for creating Follow instances."""

    class Meta:
        model = Follow

    follower = factory.SubFactory(UserFactory)
    following = factory.SubFactory(UserFactory)
