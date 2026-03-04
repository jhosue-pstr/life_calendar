from typing import List, Optional

from sqlalchemy.orm import Session

from app.models.goal import Goal, GoalDay
from app.repositories.base_repository import BaseRepository


class GoalRepository(BaseRepository[Goal]):
    def get_by_user(
        self,
        db: Session,
        user_id: int,
        active_only: bool = False
    ) -> List[Goal]:
        query = db.query(self.model).filter(Goal.user_id == user_id)
        if active_only:
            query = query.filter(Goal.is_active == True)
        return query.all()

    def get_by_user_and_id(
        self,
        db: Session,
        user_id: int,
        goal_id: int
    ) -> Optional[Goal]:
        return db.query(self.model).filter(
            Goal.id == goal_id,
            Goal.user_id == user_id
        ).first()


class GoalDayRepository(BaseRepository[GoalDay]):
    def get_by_goal(self, db: Session, goal_id: int) -> List[GoalDay]:
        return db.query(self.model).filter(GoalDay.goal_id == goal_id).all()

    def get_by_goal_and_day(
        self,
        db: Session,
        goal_id: int,
        day_number: int
    ) -> Optional[GoalDay]:
        return db.query(self.model).filter(
            GoalDay.goal_id == goal_id,
            GoalDay.day_number == day_number
        ).first()


goal_repository = GoalRepository(Goal)
goal_day_repository = GoalDayRepository(GoalDay)
