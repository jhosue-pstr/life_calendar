from sqlalchemy import Column, Integer, Date, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.database import Base


class Contribution(Base):
    __tablename__ = "contributions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    date = Column(Date, nullable=False)
    level = Column(Integer, default=0)

    user = relationship("User", back_populates="contributions")

    __table_args__ = (
        UniqueConstraint('user_id', 'date', name='uix_user_date'),
    )
