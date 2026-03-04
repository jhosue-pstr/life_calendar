from pydantic import BaseModel
from datetime import date
from typing import List


class ContributionBase(BaseModel):
    date: date
    level: int = 0


class ContributionCreate(ContributionBase):
    pass


class ContributionResponse(ContributionBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True


class ContributionYearResponse(BaseModel):
    contributions: List[ContributionResponse]
