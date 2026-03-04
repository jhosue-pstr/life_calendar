from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date

from app.database import get_db
from app.models.user import User
from app.models.activity import Activity
from app.schemas.activity import ActivityCreate, ActivityUpdate, ActivityResponse
from app.utils.auth import get_current_user
from app.utils.contributions import update_contributions

router = APIRouter(prefix="/activities", tags=["activities"])


@router.get("", response_model=List[ActivityResponse])
def get_activities(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    date_filter: date = None
):
    query = db.query(Activity).filter(Activity.user_id == current_user.id)
    if date_filter:
        query = query.filter(Activity.date == date_filter)
    return query.order_by(Activity.date.desc()).all()


@router.post("", response_model=ActivityResponse)
def create_activity(
    activity: ActivityCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_activity = Activity(
        user_id=current_user.id,
        title=activity.title,
        date=activity.date,
        is_done=False
    )
    db.add(db_activity)
    db.commit()
    db.refresh(db_activity)

    update_contributions(db, current_user.id, activity.date)

    return db_activity


@router.put("/{activity_id}", response_model=ActivityResponse)
def update_activity(
    activity_id: int,
    activity_update: ActivityUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_activity = db.query(Activity).filter(
        Activity.id == activity_id,
        Activity.user_id == current_user.id
    ).first()

    if not db_activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    if activity_update.title is not None:
        db_activity.title = activity_update.title
    if activity_update.is_done is not None:
        db_activity.is_done = activity_update.is_done

    db.commit()
    db.refresh(db_activity)

    update_contributions(db, current_user.id, db_activity.date)

    return db_activity


@router.delete("/{activity_id}")
def delete_activity(
    activity_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_activity = db.query(Activity).filter(
        Activity.id == activity_id,
        Activity.user_id == current_user.id
    ).first()

    if not db_activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    activity_date = db_activity.date
    db.delete(db_activity)
    db.commit()

    update_contributions(db, current_user.id, activity_date)

    return {"detail": "Activity deleted"}
