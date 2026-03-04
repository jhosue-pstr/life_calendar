from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date, timedelta
from dateutil.relativedelta import relativedelta

from app.database import get_db
from app.models.user import User
from app.models.bad_habit import BadHabit
from app.schemas.bad_habit import BadHabitCreate, BadHabitUpdate, BadHabitResponse
from app.utils.auth import get_current_user
from app.utils.contributions import update_contributions

router = APIRouter(prefix="/bad-habits", tags=["bad-habits"])


@router.get("", response_model=List[BadHabitResponse])
def get_bad_habits(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(BadHabit).filter(BadHabit.user_id == current_user.id).all()


@router.post("", response_model=BadHabitResponse)
def create_bad_habit(
    habit: BadHabitCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = BadHabit(
        user_id=current_user.id,
        name=habit.name,
        current_streak=0,
        longest_streak=0
    )
    db.add(db_habit)
    db.commit()
    db.refresh(db_habit)
    return db_habit


@router.put("/{habit_id}", response_model=BadHabitResponse)
def update_bad_habit(
    habit_id: int,
    habit_update: BadHabitUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = db.query(BadHabit).filter(
        BadHabit.id == habit_id,
        BadHabit.user_id == current_user.id
    ).first()

    if not db_habit:
        raise HTTPException(status_code=404, detail="Bad habit not found")

    if habit_update.name is not None:
        db_habit.name = habit_update.name

    db.commit()
    db.refresh(db_habit)
    return db_habit


@router.post("/{habit_id}/relapse", response_model=BadHabitResponse)
def trigger_relapse(
    habit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = db.query(BadHabit).filter(
        BadHabit.id == habit_id,
        BadHabit.user_id == current_user.id
    ).first()

    if not db_habit:
        raise HTTPException(status_code=404, detail="Bad habit not found")

    if db_habit.current_streak > db_habit.longest_streak:
        db_habit.longest_streak = db_habit.current_streak

    db_habit.current_streak = 0
    db_habit.last_relapse_date = date.today()

    db.commit()
    db.refresh(db_habit)

    update_contributions(db, current_user.id, date.today())

    return db_habit


@router.post("/{habit_id}/increment", response_model=BadHabitResponse)
def increment_streak(
    habit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = db.query(BadHabit).filter(
        BadHabit.id == habit_id,
        BadHabit.user_id == current_user.id
    ).first()

    if not db_habit:
        raise HTTPException(status_code=404, detail="Bad habit not found")

    db_habit.current_streak += 1
    if db_habit.current_streak > db_habit.longest_streak:
        db_habit.longest_streak = db_habit.current_streak

    db.commit()
    db.refresh(db_habit)

    update_contributions(db, current_user.id, date.today())

    return db_habit


@router.delete("/{habit_id}")
def delete_bad_habit(
    habit_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_habit = db.query(BadHabit).filter(
        BadHabit.id == habit_id,
        BadHabit.user_id == current_user.id
    ).first()

    if not db_habit:
        raise HTTPException(status_code=404, detail="Bad habit not found")

    db.delete(db_habit)
    db.commit()

    return {"detail": "Bad habit deleted"}
