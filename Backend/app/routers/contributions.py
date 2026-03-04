from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date, datetime

from app.database import get_db
from app.models.user import User
from app.models.contribution import Contribution
from app.schemas.contribution import ContributionResponse, ContributionYearResponse
from app.utils.auth import get_current_user

router = APIRouter(prefix="/contributions", tags=["contributions"])


@router.get("", response_model=List[ContributionResponse])
def get_contributions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    year: int = None
):
    query = db.query(Contribution).filter(Contribution.user_id == current_user.id)
    if year:
        start_date = date(year, 1, 1)
        end_date = date(year, 12, 31)
        query = query.filter(Contribution.date >= start_date, Contribution.date <= end_date)
    return query.order_by(Contribution.date).all()


@router.get("/year/{year}", response_model=ContributionYearResponse)
def get_contributions_by_year(
    year: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    start_date = date(year, 1, 1)
    end_date = date(year, 12, 31)

    contributions = db.query(Contribution).filter(
        Contribution.user_id == current_user.id,
        Contribution.date >= start_date,
        Contribution.date <= end_date
    ).order_by(Contribution.date).all()

    return {"contributions": contributions}
