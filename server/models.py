from sqlalchemy import Column, Integer, String
from database import Base

class Entry(Base):
    __tablename__ = "entries"

    id = Column(Integer, primary_key=True, index=True)
    type = Column(String)
    vehicle_no = Column(String)
    party = Column(String)
    item = Column(String)
    quantity = Column(String)
    document_no = Column(String)
    image_path = Column(String)
    timestamp = Column(String)