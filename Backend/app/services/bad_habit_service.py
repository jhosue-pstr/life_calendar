from typing import List, Optional
from datetime import date

from sqlalchemy.orm import Session

from app.models.bad_habit import BadHabit
from app.repositories import bad_habit_repository
from app.schemas.bad_habit import BadHabitCreate, BadHabitUpdate


class BadHabitService:
    def get_habits(
        self,
        db: Session,
        user_id: int
    ) -> List[BadHabit]:
        return bad_habit_repository.get_by_user(db, user_id)

    def create(
        self,
        db: Session,
        user_id: int,
        habit_in: BadHabitCreate
    ) -> BadHabit:
        return bad_habit_repository.create(db, {
            "user_id": user_id,
            "name": habit_in.name,
            "current_streak": 0,
            "longest_streak": 0
        })

    def update(
        self,
        db: Session,
        user_id: int,
        habit_id: int,
        habit_update: BadHabitUpdate
    ) -> Optional[BadHabit]:
        db_habit = bad_habit_repository.get_by_user_and_id(db, user_id, habit_id)
        if not db_habit:
            return None

        update_data = habit_update.model_dump(exclude_unset=True)
        return bad_habit_repository.update(db, db_habit, update_data)

    def relapse(
        self,
        db: Session,
        user_id: int,
        habit_id: int
    ) -> Optional[BadHabit]:
        db_habit = bad_habit_repository.get_by_user_and_id(db, user_id, habit_id)
        if not db_habit:
            return None

        if db_habit.current_streak > db_habit.longest_streak:
            db_habit.longest_streak = db_habit.current_streak

        db_habit.current_streak = 0
        db_habit.last_relapse_date = date.today()

        db.commit()
        db.refresh(db_habit)
        return db_habit

    def increment(
        self,
        db: Session,
        user_id: int,
        habit_id: int
    ) -> Optional[BadHabit]:
        db_habit = bad_habit_repository.get_by_user_and_id(db, user_id, habit_id)
        if not db_habit:
            return None

        db_habit.current_streak += 1
        if db_habit.current_streak > db_habit.longest_streak:
            db_habit.longest_streak = db_habit.current_streak

        db.commit()
        db.refresh(db_habit)
        return db_habit

    def delete(
        self,
        db: Session,
        user_id: int,
        habit_id: int
    ) -> bool:
        db_habit = bad_habit_repository.get_by_user_and_id(db, user_id, habit_id)
        if not db_habit:
            return False

        return bad_habit_repository.delete(db, habit_id)


bad_habit_service = BadHabitService()
