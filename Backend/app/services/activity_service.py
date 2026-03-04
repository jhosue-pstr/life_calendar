from typing import List, Optional
from datetime import date

from sqlalchemy.orm import Session

from app.models.activity import Activity
from app.repositories import activity_repository
from app.schemas.activity import ActivityCreate, ActivityUpdate


class ActivityService:
    def get_activities(
        self,
        db: Session,
        user_id: int,
        date_filter: Optional[date] = None
    ) -> List[Activity]:
        return activity_repository.get_by_user(db, user_id, date_filter)

    def create(
        self,
        db: Session,
        user_id: int,
        activity_in: ActivityCreate
    ) -> Activity:
        return activity_repository.create(db, {
            "user_id": user_id,
            "title": activity_in.title,
            "date": activity_in.date,
            "is_done": False
        })

    def update(
        self,
        db: Session,
        user_id: int,
        activity_id: int,
        activity_update: ActivityUpdate
    ) -> Optional[Activity]:
        db_activity = activity_repository.get_by_user_and_date(db, user_id, activity_id)
        if not db_activity:
            return None

        update_data = activity_update.model_dump(exclude_unset=True)
        return activity_repository.update(db, db_activity, update_data)

    def delete(
        self,
        db: Session,
        user_id: int,
        activity_id: int
    ) -> Optional[Activity]:
        db_activity = activity_repository.get_by_user_and_date(db, user_id, activity_id)
        if not db_activity:
            return None

        activity_repository.delete(db, activity_id)
        return db_activity


activity_service = ActivityService()
