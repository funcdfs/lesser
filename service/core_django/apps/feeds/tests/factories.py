"""
Factory classes for Feed interaction models.
"""
import factory
from factory.django import DjangoModelFactory

from apps.feeds.models import Bookmark, Comment, Like, Repost
from apps.posts.tests.factories import PostFactory
from apps.users.tests.factories import UserFactory


class LikeFactory(DjangoModelFactory):
    """Factory for creating Like instances."""

    class Meta:
        model = Like

    user = factory.SubFactory(UserFactory)
    post = factory.SubFactory(PostFactory)


class RepostFactory(DjangoModelFactory):
    """Factory for creating Repost instances."""

    class Meta:
        model = Repost

    user = factory.SubFactory(UserFactory)
    post = factory.SubFactory(PostFactory)
    quote = factory.Faker('sentence')


class CommentFactory(DjangoModelFactory):
    """Factory for creating Comment instances."""

    class Meta:
        model = Comment

    author = factory.SubFactory(UserFactory)
    post = factory.SubFactory(PostFactory)
    content = factory.Faker('sentence')
    is_deleted = False


class BookmarkFactory(DjangoModelFactory):
    """Factory for creating Bookmark instances."""

    class Meta:
        model = Bookmark

    user = factory.SubFactory(UserFactory)
    post = factory.SubFactory(PostFactory)
