from typing import List, Optional

from sqlalchemy.orm import Session

from app.models.bad_habit import BadHabit
from app.repositories.base_repository import BaseRepository


class BadHabitRepository(BaseRepository[BadHabit]):
    def get_by_user(self, db: Session, user_id: int) -> List[BadHabit]:
        return db.query(self.model).filter(BadHabit.user_id == user_id).all()

    def get_by_user_and_id(
        self,
        db: Session,
        user_id: int,
        habit_id: int
    ) -> Optional[BadHabit]:
        return db.query(self.model).filter(
            BadHabit.id == habit_id,
            BadHabit.user_id == user_id
        ).first()


bad_habit_repository = BadHabitRepository(BadHabit)
