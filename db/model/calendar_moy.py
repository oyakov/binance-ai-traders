from sqlalchemy import Column, Integer, Boolean

from db.config import Base


class CalendarMoY(Base):
    __tablename__ = "calendar_moy"
    id = Column(Integer, primary_key=True, index=True)
    january = Column(Boolean, unique=False, index=False)
    february = Column(Boolean, unique=False, index=False)
    march = Column(Boolean, unique=False, index=False)
    april = Column(Boolean, unique=False, index=False)
    may = Column(Boolean, unique=False, index=False)
    june = Column(Boolean, unique=False, index=False)
    july = Column(Boolean, unique=False, index=False)
    august = Column(Boolean, unique=False, index=False)
    september = Column(Boolean, unique=False, index=False)
    october = Column(Boolean, unique=False, index=False)
    november = Column(Boolean, unique=False, index=False)
    december = Column(Boolean, unique=False, index=False)
