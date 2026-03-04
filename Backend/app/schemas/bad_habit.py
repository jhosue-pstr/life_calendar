from pydantic import BaseModel
from datetime import date
from typing import Optional


class BadHabitBase(BaseModel):
    name: str


class BadHabitCreate(BadHabitBase):
    pass


class BadHabitUpdate(BaseModel):
    name: Optional[str] = None


class BadHabitResponse(BadHabitBase):
    id: int
    user_id: int
    current_streak: int
    longest_streak: int
    last_relapse_date: Optional[date] = None

    class Config:
        from_attributes = True
