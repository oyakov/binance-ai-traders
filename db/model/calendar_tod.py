from sqlalchemy import Column, Integer, Boolean

from db.config import Base


class CalendarToD(Base):
    __tablename__ = "calendar_tod"
    id = Column(Integer, primary_key=True, index=True)
    time_10_00 = Column(Boolean, unique=False, index=False)
    time_12_00 = Column(Boolean, unique=False, index=False)
    time_14_00 = Column(Boolean, unique=False, index=False)
    time_16_00 = Column(Boolean, unique=False, index=False)
    time_18_00 = Column(Boolean, unique=False, index=False)
    time_20_00 = Column(Boolean, unique=False, index=False)
    time_22_00 = Column(Boolean, unique=False, index=False)
