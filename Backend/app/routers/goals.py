from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.models.user import User
from app.models.goal import Goal, GoalDay
from app.schemas.goal import GoalCreate, GoalUpdate, GoalResponse, GoalDayToggle
from app.utils.auth import get_current_user

router = APIRouter(prefix="/goals", tags=["goals"])


@router.get("", response_model=List[GoalResponse])
def get_goals(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    active_only: bool = False
):
    query = db.query(Goal).filter(Goal.user_id == current_user.id)
    if active_only:
        query = query.filter(Goal.is_active == True)
    return query.order_by(Goal.created_at.desc()).all()


@router.post("", response_model=GoalResponse)
def create_goal(
    goal: GoalCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_goal = Goal(
        user_id=current_user.id,
        title=goal.title,
        target_days=goal.target_days,
        start_date=goal.start_date,
        is_active=True
    )
    db.add(db_goal)
    db.commit()
    db.refresh(db_goal)

    for i in range(1, goal.target_days + 1):
        db_goal_day = GoalDay(
            goal_id=db_goal.id,
            day_number=i,
            is_completed=False
        )
        db.add(db_goal_day)

    db.commit()
    db.refresh(db_goal)

    return db_goal


@router.put("/{goal_id}", response_model=GoalResponse)
def update_goal(
    goal_id: int,
    goal_update: GoalUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_id == current_user.id
    ).first()

    if not db_goal:
        raise HTTPException(status_code=404, detail="Goal not found")

    if goal_update.title is not None:
        db_goal.title = goal_update.title
    if goal_update.is_active is not None:
        db_goal.is_active = goal_update.is_active

    db.commit()
    db.refresh(db_goal)

    return db_goal


@router.patch("/{goal_id}/days", response_model=GoalResponse)
def toggle_goal_day(
    goal_id: int,
    day_toggle: GoalDayToggle,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_id == current_user.id
    ).first()

    if not db_goal:
        raise HTTPException(status_code=404, detail="Goal not found")

    db_goal_day = db.query(GoalDay).filter(
        GoalDay.goal_id == goal_id,
        GoalDay.day_number == day_toggle.day_number
    ).first()

    if not db_goal_day:
        raise HTTPException(status_code=404, detail="Goal day not found")

    db_goal_day.is_completed = day_toggle.is_completed
    if day_toggle.is_completed:
        db_goal_day.completed_at = datetime.utcnow()
    else:
        db_goal_day.completed_at = None

    db.commit()
    db.refresh(db_goal)

    return db_goal


@router.delete("/{goal_id}")
def delete_goal(
    goal_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_id == current_user.id
    ).first()

    if not db_goal:
        raise HTTPException(status_code=404, detail="Goal not found")

    db.delete(db_goal)
    db.commit()

    return {"detail": "Goal deleted"}
