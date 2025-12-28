"""
Factory classes for Post models.
"""
import factory
from factory.django import DjangoModelFactory

from apps.posts.models import Post, PostMedia, PostType
from apps.users.tests.factories import UserFactory


class PostFactory(DjangoModelFactory):
    """Factory for creating Post instances."""

    class Meta:
        model = Post

    author = factory.SubFactory(UserFactory)
    post_type = PostType.SHORT
    title = factory.Faker('sentence')
    content = factory.Faker('paragraph')
    media_urls = []
    is_deleted = False


class StoryPostFactory(PostFactory):
    """Factory for creating Story posts."""

    post_type = PostType.STORY


class ColumnPostFactory(PostFactory):
    """Factory for creating Column posts."""

    post_type = PostType.COLUMN
    title = factory.Faker('sentence')
    content = factory.Faker('text', max_nb_chars=2000)


class PostMediaFactory(DjangoModelFactory):
    """Factory for creating PostMedia instances."""

    class Meta:
        model = PostMedia

    post = factory.SubFactory(PostFactory)
    url = factory.Faker('image_url')
    media_type = 'image'
    order = factory.Sequence(lambda n: n)
