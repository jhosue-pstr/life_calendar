from typing import List, Optional
from datetime import datetime

from sqlalchemy.orm import Session

from app.models.goal import Goal, GoalDay
from app.repositories import goal_repository, goal_day_repository
from app.schemas.goal import GoalCreate, GoalUpdate, GoalDayToggle


class GoalService:
    def get_goals(
        self,
        db: Session,
        user_id: int,
        active_only: bool = False
    ) -> List[Goal]:
        return goal_repository.get_by_user(db, user_id, active_only)

    def create(
        self,
        db: Session,
        user_id: int,
        goal_in: GoalCreate
    ) -> Goal:
        db_goal = goal_repository.create(db, {
            "user_id": user_id,
            "title": goal_in.title,
            "target_days": goal_in.target_days,
            "start_date": goal_in.start_date,
            "is_active": True
        })

        for i in range(1, goal_in.target_days + 1):
            goal_day_repository.create(db, {
                "goal_id": db_goal.id,
                "day_number": i,
                "is_completed": False
            })

        return db_goal

    def update(
        self,
        db: Session,
        user_id: int,
        goal_id: int,
        goal_update: GoalUpdate
    ) -> Optional[Goal]:
        db_goal = goal_repository.get_by_user_and_id(db, user_id, goal_id)
        if not db_goal:
            return None

        update_data = goal_update.model_dump(exclude_unset=True)
        return goal_repository.update(db, db_goal, update_data)

    def toggle_day(
        self,
        db: Session,
        user_id: int,
        goal_id: int,
        day_toggle: GoalDayToggle
    ) -> Optional[Goal]:
        db_goal = goal_repository.get_by_user_and_id(db, user_id, goal_id)
        if not db_goal:
            return None

        db_goal_day = goal_day_repository.get_by_goal_and_day(
            db, goal_id, day_toggle.day_number
        )
        if not db_goal_day:
            return None

        db_goal_day.is_completed = day_toggle.is_completed
        if day_toggle.is_completed:
            db_goal_day.completed_at = datetime.utcnow()
        else:
            db_goal_day.completed_at = None

        db.commit()
        db.refresh(db_goal)
        return db_goal

    def delete(
        self,
        db: Session,
        user_id: int,
        goal_id: int
    ) -> bool:
        db_goal = goal_repository.get_by_user_and_id(db, user_id, goal_id)
        if not db_goal:
            return False

        return goal_repository.delete(db, goal_id)


goal_service = GoalService()
