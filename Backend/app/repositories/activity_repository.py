from datetime import date
from typing import List, Optional

from sqlalchemy.orm import Session

from app.models.activity import Activity
from app.repositories.base_repository import BaseRepository


class ActivityRepository(BaseRepository[Activity]):
    def get_by_user(
        self,
        db: Session,
        user_id: int,
        date_filter: Optional[date] = None
    ) -> List[Activity]:
        query = db.query(self.model).filter(Activity.user_id == user_id)
        if date_filter:
            query = query.filter(Activity.date == date_filter)
        return query.order_by(Activity.date.desc()).all()

    def get_by_user_and_date(
        self,
        db: Session,
        user_id: int,
        activity_id: int
    ) -> Optional[Activity]:
        return db.query(self.model).filter(
            Activity.id == activity_id,
            Activity.user_id == user_id
        ).first()


activity_repository = ActivityRepository(Activity)
