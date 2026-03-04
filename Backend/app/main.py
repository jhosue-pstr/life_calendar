from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings
from app.core.database import init_db
from app.api.v1.router import api_router

settings = get_settings()

app = FastAPI(
    title="Life Calendar API",
    description="Backend for Life Calendar - Track your daily activities, goals, and habits",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.on_event("startup")
def startup_event():
    init_db()


@app.get("/")
def root():
    return {"message": "Life Calendar API", "status": "running"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}
