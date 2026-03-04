from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.schemas.goal import GoalCreate, GoalUpdate, GoalResponse, GoalDayToggle
from app.services import goal_service

router = APIRouter(prefix="/goals", tags=["goals"])


@router.get("", response_model=List[GoalResponse])
def get_goals(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    active_only: bool = False
):
    return goal_service.get_goals(db, current_user.id, active_only)


@router.post("", response_model=GoalResponse, status_code=201)
def create_goal(
    goal: GoalCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return goal_service.create(db, current_user.id, goal)


@router.put("/{goal_id}", response_model=GoalResponse)
def update_goal(
    goal_id: int,
    goal_update: GoalUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_goal = goal_service.update(db, current_user.id, goal_id, goal_update)
    if not db_goal:
        raise HTTPException(status_code=404, detail="Goal not found")
    return db_goal


@router.patch("/{goal_id}/days", response_model=GoalResponse)
def toggle_goal_day(
    goal_id: int,
    day_toggle: GoalDayToggle,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_goal = goal_service.toggle_day(db, current_user.id, goal_id, day_toggle)
    if not db_goal:
        raise HTTPException(status_code=404, detail="Goal or day not found")
    return db_goal


@router.delete("/{goal_id}")
def delete_goal(
    goal_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    deleted = goal_service.delete(db, current_user.id, goal_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Goal not found")
    return {"detail": "Goal deleted"}
