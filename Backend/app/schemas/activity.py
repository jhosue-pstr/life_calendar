from pydantic import BaseModel
from datetime import date
from typing import Optional


class ActivityBase(BaseModel):
    title: str
    date: date


class ActivityCreate(ActivityBase):
    pass


class ActivityUpdate(BaseModel):
    title: Optional[str] = None
    is_done: Optional[bool] = None


class ActivityResponse(ActivityBase):
    id: int
    user_id: int
    is_done: bool

    class Config:
        from_attributes = True
