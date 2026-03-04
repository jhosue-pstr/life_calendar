from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    nickname = Column(String(100), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    activities = relationship("Activity", back_populates="user", cascade="all, delete-orphan")
    goals = relationship("Goal", back_populates="user", cascade="all, delete-orphan")
    bad_habits = relationship("BadHabit", back_populates="user", cascade="all, delete-orphan")
    contributions = relationship("Contribution", back_populates="user", cascade="all, delete-orphan")
