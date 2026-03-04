from sqlalchemy.orm import Session
from datetime import date, datetime
from app.models.activity import Activity
from app.models.bad_habit import BadHabit
from app.models.contribution import Contribution


def calculate_level(activities_done: int, bad_habits_streak: int) -> int:
    """
    Calcula el nivel de contribución basado en actividades y malos hábitos.
    
    Nivel 0: 0 actividades
    Nivel 1: 1-2 actividades
    Nivel 2: 3-4 actividades
    Nivel 3: 5-6 actividades
    Nivel 4: 7+ actividades
    
    Cada mal hábito sin recaída suma 1 nivel extra.
    """
    if activities_done == 0 and bad_habits_streak == 0:
        return 0
    
    base_level = min(activities_done // 2, 4)
    bonus = min(bad_habits_streak, 2)
    
    return min(base_level + bonus, 4)


def update_contributions(db: Session, user_id: int, target_date: date):
    """
    Actualiza el nivel de contribución para una fecha específica.
    Se llama cada vez que se modifica una actividad o un mal hábito.
    """
    activities_count = db.query(Activity).filter(
        Activity.user_id == user_id,
        Activity.date == target_date,
        Activity.is_done == True
    ).count()
    
    bad_habits_streak = db.query(BadHabit).filter(
        BadHabit.user_id == user_id,
        BadHabit.last_relapse_date < target_date
    ).count()
    
    level = calculate_level(activities_count, bad_habits_streak)
    
    contribution = db.query(Contribution).filter(
        Contribution.user_id == user_id,
        Contribution.date == target_date
    ).first()
    
    if contribution:
        contribution.level = level
    else:
        contribution = Contribution(
            user_id=user_id,
            date=target_date,
            level=level
        )
        db.add(contribution)
    
    db.commit()
