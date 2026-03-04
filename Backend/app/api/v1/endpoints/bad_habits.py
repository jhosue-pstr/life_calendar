from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date

from app.core.database import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.schemas.bad_habit import BadHabitCreate, BadHabitUpdate, BadHabitResponse
from app.services import bad_habit_service
from app.utils.contributions import update_contributions

router = APIRouter(prefix="/bad-habits", tags=["bad-habits"])


@router.get("", response_model=List[BadHabitResponse])
def get_bad_habits(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return bad_habit_service.get_habits(db, current_user.id)


@router.post("", response_model=BadHabitResponse, status_code=201)
def create_bad_habit(
    habit: BadHabitCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return bad_habit_service.create(db, current_user.id, habit)


@router.put("/{habit_id}", response_model=BadHabitResponse)
def update_bad_habit(
    habit_id: int,
    habit_update: BadHabitUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = bad_habit_service.update(db, current_user.id, habit_id, habit_update)
    if not db_habit:
        raise HTTPException(status_code=404, detail="Bad habit not found")
    return db_habit


@router.post("/{habit_id}/relapse", response_model=BadHabitResponse)
def trigger_relapse(
    habit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = bad_habit_service.relapse(db, current_user.id, habit_id)
    if not db_habit:
        raise HTTPException(status_code=404, detail="Bad habit not found")

    update_contributions(db, current_user.id, date.today())
    return db_habit


@router.post("/{habit_id}/increment", response_model=BadHabitResponse)
def increment_streak(
    habit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = bad_habit_service.increment(db, current_user.id, habit_id)
    if not db_habit:
        raise HTTPException(status_code=404, detail="Bad habit not found")

    update_contributions(db, current_user.id, date.today())
    return db_habit


@router.delete("/{habit_id}")
def delete_bad_habit(
    habit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    deleted = bad_habit_service.delete(db, current_user.id, habit_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Bad habit not found")
    return {"detail": "Bad habit deleted"}
