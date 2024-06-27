from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from db.config import Base


class CalendarData(Base):
    __tablename__ = "calendar_data"
    id = Column(Integer, primary_key=True, index=True)
    
    dow_id = Column(Integer, ForeignKey('calendar_dow.id'), nullable=False)
    dom_id = Column(Integer, ForeignKey('calendar_dom.id'), nullable=False)
    moy_id = Column(Integer, ForeignKey('calendar_moy.id'), nullable=False)
    tod_id = Column(Integer, ForeignKey('calendar_tod.id'), nullable=False)
    
    data = Column(String, nullable=True)
    username = Column(String, nullable=False)
    
    dow = relationship("CalendarDoW")
    dom = relationship("CalendarDoM")
    moy = relationship("CalendarMoY")
    tod = relationship("CalendarToD")
