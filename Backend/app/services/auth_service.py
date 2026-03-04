from typing import Optional
from datetime import timedelta

from sqlalchemy.orm import Session

from app.models.user import User
from app.repositories import user_repository
from app.schemas.user import UserCreate
from app.core.security import get_password_hash, verify_password, create_access_token
from app.core.config import get_settings

settings = get_settings()


class AuthService:
    def register(self, db: Session, user_in: UserCreate) -> User:
        existing = user_repository.get_by_email(db, user_in.email)
        if existing:
            raise ValueError("Email already registered")

        hashed_password = get_password_hash(user_in.password)
        return user_repository.create(db, {
            "email": user_in.email,
            "password_hash": hashed_password,
            "nickname": user_in.nickname
        })

    def authenticate(
        self,
        db: Session,
        email: str,
        password: str
    ) -> Optional[User]:
        user = user_repository.get_by_email_with_password(db, email)
        if not user:
            return None
        if not verify_password(password, user.password_hash):
            return None
        return user

    def create_token(self, user: User) -> dict:
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.email},
            expires_delta=access_token_expires
        )
        return {"access_token": access_token, "token_type": "bearer"}


auth_service = AuthService()
