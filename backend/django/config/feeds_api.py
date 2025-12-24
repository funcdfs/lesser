from ninja import Router
from typing import List
from social.models import Post

router = Router()

@router.get("/", response=List[dict])
def list_feeds(request):
    posts = Post.objects.all()
    return [
        {
            "id": str(p.id),
            "username": p.username,
            "content": p.content,
            "created_at": p.created_at.isoformat(),
            "likes": p.likes,
            "location": p.location,
            "comments_count": p.comments_count,
            "reposts_count": p.reposts_count,
            "bookmarks_count": p.bookmarks_count,
            "shares_count": p.shares_count,
            "is_liked": False,  # Placeholder for now
        }
        for p in posts
    ]
