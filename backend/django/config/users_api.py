from ninja import Router, Schema
from django.contrib.auth.models import User
from typing import Optional

router = Router()

class UserOut(Schema):
    id: int
    username: str
    email: str
    first_name: Optional[str]
    last_name: Optional[str]

@router.get("/me", response=UserOut)
def get_me(request):
    if request.user.is_authenticated:
        return request.user
    # Fallback for development if not logged in
    return User(
        id=0,
        username="guest_user",
        email="guest@example.com",
        first_name="Guest",
        last_name="User"
    )
