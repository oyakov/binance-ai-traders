from sqlalchemy import Column, Integer, Boolean, String, ForeignKey
from sqlalchemy.orm import relationship

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


class CalendarDoM(Base):
    __tablename__ = "calendar_dom"
    id = Column(Integer, primary_key=True, index=True)
    day_1 = Column(Boolean, unique=False, index=False)
    day_2 = Column(Boolean, unique=False, index=False)
    day_3 = Column(Boolean, unique=False, index=False)
    day_4 = Column(Boolean, unique=False, index=False)
    day_5 = Column(Boolean, unique=False, index=False)
    day_6 = Column(Boolean, unique=False, index=False)
    day_7 = Column(Boolean, unique=False, index=False)
    day_8 = Column(Boolean, unique=False, index=False)
    day_9 = Column(Boolean, unique=False, index=False)
    day_10 = Column(Boolean, unique=False, index=False)
    day_11 = Column(Boolean, unique=False, index=False)
    day_12 = Column(Boolean, unique=False, index=False)
    day_13 = Column(Boolean, unique=False, index=False)
    day_14 = Column(Boolean, unique=False, index=False)
    day_15 = Column(Boolean, unique=False, index=False)
    day_16 = Column(Boolean, unique=False, index=False)
    day_17 = Column(Boolean, unique=False, index=False)
    day_18 = Column(Boolean, unique=False, index=False)
    day_19 = Column(Boolean, unique=False, index=False)
    day_20 = Column(Boolean, unique=False, index=False)
    day_21 = Column(Boolean, unique=False, index=False)
    day_22 = Column(Boolean, unique=False, index=False)
    day_23 = Column(Boolean, unique=False, index=False)
    day_24 = Column(Boolean, unique=False, index=False)
    day_25 = Column(Boolean, unique=False, index=False)
    day_26 = Column(Boolean, unique=False, index=False)
    day_27 = Column(Boolean, unique=False, index=False)
    day_28 = Column(Boolean, unique=False, index=False)
    day_29 = Column(Boolean, unique=False, index=False)
    day_30 = Column(Boolean, unique=False, index=False)
    day_31 = Column(Boolean, unique=False, index=False)


class CalendarData(Base):
    __tablename__ = "calendar_data"
    id = Column(Integer, primary_key=True, index=True)

    # Calendar data
    dow_id = Column(Integer, ForeignKey('calendar_dow.id'), nullable=False)
    dom_id = Column(Integer, ForeignKey('calendar_dom.id'), nullable=False)
    moy_id = Column(Integer, ForeignKey('calendar_moy.id'), nullable=False)
    tod_id = Column(Integer, ForeignKey('calendar_tod.id'), nullable=False)

    # Telegram chat_id
    chat_id = Column(String, ForeignKey('telegram_group.chat_id'), nullable=False)
    # Text to post
    data = Column(String, nullable=False)
    # Username of the customer
    username = Column(String, nullable=False)

    dow = relationship("CalendarDoW")
    dom = relationship("CalendarDoM")
    moy = relationship("CalendarMoY")
    tod = relationship("CalendarToD")
    tg_chat = relationship("TelegramGroup")
