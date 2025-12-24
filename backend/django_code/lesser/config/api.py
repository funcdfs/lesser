from ninja import NinjaAPI
from .feeds_api import router as feeds_router
from .users_api import router as users_router

api = NinjaAPI(
    title="Lesser API",
    version="1.0.0",
    description="Backend API for the Lesser social platform",
)

@api.get("/health")
def health(request):
    return {"status": "ok", "message": "Lesser backend is running smoothly"}

api.add_router("/feeds", feeds_router)
api.add_router("/users", users_router)
