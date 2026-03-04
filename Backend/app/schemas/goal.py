from pydantic import BaseModel
from datetime import date, datetime
from typing import List, Optional


class GoalDayBase(BaseModel):
    day_number: int
    is_completed: bool = False


class GoalDayResponse(GoalDayBase):
    id: int
    goal_id: int
    completed_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class GoalBase(BaseModel):
    title: str
    target_days: int
    start_date: date


class GoalCreate(GoalBase):
    pass


class GoalUpdate(BaseModel):
    title: Optional[str] = None
    is_active: Optional[bool] = None


class GoalDayToggle(BaseModel):
    day_number: int
    is_completed: bool


class GoalResponse(GoalBase):
    id: int
    user_id: int
    is_active: bool
    goal_days: List[GoalDayResponse] = []

    class Config:
        from_attributes = True
