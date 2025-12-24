from ninja import Router
from typing import List
from datetime import datetime

router = Router()

@router.get("/", response=List[dict])
def list_feeds(request):
    return [
        {
            "id": "1",
            "username": "antigravity",
            "content": "Hello from Django Ninja! This is an optimized architecture integration.",
            "created_at": datetime.now().isoformat(),
            "likes": 42,
        },
        {
            "id": "2",
            "username": "flutter_dev",
            "content": "Riverpod + Django Ninja = 🚀",
            "created_at": datetime.now().isoformat(),
            "likes": 99,
        }
    ]
