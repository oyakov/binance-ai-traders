from sqlalchemy import Column, Integer, Boolean

from db.config import Base


class CalendarDoW(Base):
    __tablename__ = "calendar_dow"
    id = Column(Integer, primary_key=True, index=True)
    monday = Column(Boolean, unique=False, index=False)
    tuesday = Column(Boolean, unique=False, index=False)
    wednesday = Column(Boolean, unique=False, index=False)
    thursday = Column(Boolean, unique=False, index=False)
    friday = Column(Boolean, unique=False, index=False)
    saturday = Column(Boolean, unique=False, index=False)
    sunday = Column(Boolean, unique=False, index=False)