from sqlalchemy.orm import Session
from fastapi import FastAPI, UploadFile, File, Depends
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from database import SessionLocal, engine
import models
import shutil
import os

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# Ensure image folder exists
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic model
class EntrySchema(BaseModel):
    type: str
    vehicle_no: str
    party: str
    item: str
    quantity: str
    document_no: str
    timestamp: str

# CREATE ENTRY (WITHOUT IMAGE)
@app.post("/entry")
def create_entry(entry: EntrySchema):
    db = SessionLocal()

    db_entry = models.Entry(**entry.dict(), image_path="")
    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)

    return {"status": "saved"}

# IMAGE UPLOAD
@app.post("/upload")
def upload_image(file: UploadFile = File(...)):
    file_path = f"{UPLOAD_FOLDER}/{file.filename}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {"file_path": file_path}

# # Temporary storage
# data_store = []

# class Item(BaseModel):
#     name: str
#     message: str

users = [
    {"username": "security1", "password": "1234", "role": "security"},
    {"username": "officer1", "password": "1234", "role": "officer"},
]

@app.post("/login")
def login(data: dict):
    for user in users:
        if user["username"] == data["username"] and user["password"] == data["password"]:
            return {"status": "success", "role": user["role"]}
    return {"status": "fail"}

# ✅ GET ALL ENTRIES
@app.get("/entries")
def get_entries(db: Session = Depends(get_db)):
    entries = db.query(models.Entry).order_by(models.Entry.id.desc()).all()

    result = []
    for e in entries:
        result.append({
            "id": e.id,
            "type": e.type,
            "vehicle_no": e.vehicle_no,
            "party": e.party,
            "item": e.item,
            "quantity": e.quantity,
            "document_no": e.document_no,
            "timestamp": e.timestamp,
            "image_path": e.image_path
        })

    return {"data": result}

from typing import Optional

# ✅ FILTERED ENTRIES
@app.get("/entries/filter")
def filter_entries(
    item: Optional[str] = None,
    type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(models.Entry)

    if item:
        query = query.filter(models.Entry.item.ilike(f"%{item}%"))

    if type:
        query = query.filter(models.Entry.type == type)

    entries = query.order_by(models.Entry.id.desc()).all()

    result = []
    for e in entries:
        result.append({
            "id": e.id,
            "type": e.type,
            "vehicle_no": e.vehicle_no,
            "party": e.party,
            "item": e.item,
            "quantity": e.quantity,
            "document_no": e.document_no,
            "timestamp": e.timestamp,
            "image_path": e.image_path
        })

    return {"data": result}



app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
# @app.post("/submit")
# def submit(item: Item):
#     data_store.append(item.dict())
#     return {"status": "saved"}

# @app.get("/data")
# def get_data():
#     return {"data": data_store}







# sudo journalctl -u fastapi -n 50 --no-pager