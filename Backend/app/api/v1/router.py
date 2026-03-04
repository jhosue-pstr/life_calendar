from fastapi import APIRouter

from app.api.v1.endpoints import auth, activities, goals, bad_habits, contributions

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(activities.router)
api_router.include_router(goals.router)
api_router.include_router(bad_habits.router)
api_router.include_router(contributions.router)
