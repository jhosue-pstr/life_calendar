from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import init_db
from app.routers import auth, activities, goals, bad_habits, contributions

app = FastAPI(
    title="Life Calendar API",
    description="Backend for Life Calendar - Track your daily activities, goals, and habits",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(activities.router)
app.include_router(goals.router)
app.include_router(bad_habits.router)
app.include_router(contributions.router)


@app.on_event("startup")
def startup_event():
    init_db()


@app.get("/")
def root():
    return {"message": "Life Calendar API", "status": "running"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}
