from sqlalchemy import Column, Integer, String, Text

from src.db.model.base import Base


class FSMState(Base):
    __tablename__ = "fsm_states"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, unique=True, index=True)
    state = Column(String, index=True)
    data = Column(Text, nullable=True)