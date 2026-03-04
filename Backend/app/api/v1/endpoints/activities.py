from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date

from app.core.database import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.schemas.activity import ActivityCreate, ActivityUpdate, ActivityResponse
from app.services import activity_service
from app.utils.contributions import update_contributions

router = APIRouter(prefix="/activities", tags=["activities"])


@router.get("", response_model=List[ActivityResponse])
def get_activities(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    date_filter: Optional[date] = None
):
    return activity_service.get_activities(db, current_user.id, date_filter)


@router.post("", response_model=ActivityResponse, status_code=201)
def create_activity(
    activity: ActivityCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_activity = activity_service.create(db, current_user.id, activity)
    update_contributions(db, current_user.id, activity.date)
    return db_activity


@router.put("/{activity_id}", response_model=ActivityResponse)
def update_activity(
    activity_id: int,
    activity_update: ActivityUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_activity = activity_service.update(db, current_user.id, activity_id, activity_update)
    if not db_activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    update_contributions(db, current_user.id, db_activity.date)
    return db_activity


@router.delete("/{activity_id}")
def delete_activity(
    activity_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_activity = activity_service.delete(db, current_user.id, activity_id)
    if not db_activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    update_contributions(db, current_user.id, db_activity.date)
    return {"detail": "Activity deleted"}
