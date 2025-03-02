import requests
import uvicorn
from bs4 import BeautifulSoup
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pymongo import MongoClient
from typing import List
import os
from dotenv import load_dotenv
from fastapi.responses import JSONResponse
from datetime import datetime

load_dotenv()
CONNECTION_STRING = os.getenv("CONNECTION_STRING")

client = MongoClient(CONNECTION_STRING)
db = client["finki_data"]
courses_collection = db["courses"]
rooms = db["rooms"]
professors_collection = db["professors"]
assistants_collection = db["assistants"]
comments_collection = db["comments"]


def scrape_course_names(url: str) -> List[str]:
    response = requests.get(url)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    course_tags = soup.find_all("a", href=lambda href: href and href.startswith("/mk/subject/"))

    course_names = [tag.text.strip() for tag in course_tags]
    return course_names

def scrape_professors(url: str) -> List[str]:
    response = requests.get(url)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    person_divs = soup.find_all("div", class_="node node-person node-teaser clearfix")
    professors = []
    for div in person_divs:
        h2 = div.find("h2")
        if h2 and h2.a:
            name = h2.a.text.strip()
            if name.startswith("д-р"):
                professors.append(name)

    return professors

def scrape_assistants(url: str) -> List[str]:
    response = requests.get(url)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")
    person_divs = soup.find_all("div", class_="node node-person node-teaser clearfix")
    assistants = []
    for div in person_divs:
        h2 = div.find("h2")
        if h2 and h2.a:
            name = h2.a.text.strip()
            if not name.startswith("д-р"):
                assistants.append(name)

    return assistants
def save_to_db(collection, data: List[str]):
    if collection.count_documents({}) == 0:
        collection.insert_many([{"name": item} for item in data])
app = FastAPI()

@app.on_event("startup")
def startup_event():
    courses_url = "https://www.finki.ukim.mk/mk/content/%D1%81%D0%BE%D1%84%D1%82%D0%B2%D0%B5%D1%80%D1%81%D0%BA%D0%BE-%D0%B8%D0%BD%D0%B6%D0%B5%D0%BD%D0%B5%D1%80%D1%81%D1%82%D0%B2%D0%BE-%D0%B8-%D0%B8%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%81%D0%BA%D0%B8-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D0%B8"
    courses = scrape_course_names(courses_url)
    save_to_db(courses_collection, courses)
    staff_url = "https://www.finki.ukim.mk/mk/staff-list/kadar/nastaven-kadar"
    professors = scrape_professors(staff_url)
    save_to_db(professors_collection, professors)

    assistants = scrape_assistants(staff_url)
    save_to_db(assistants_collection, assistants)

@app.get("/courses")
def get_courses():
    courses = courses_collection.find({}, {"_id": 0, "name": 1})
    course_list = [course["name"] for course in courses]
    return JSONResponse(content={"courses": course_list}, media_type="application/json; charset=utf-8")

@app.get("/professors")
def get_professors():
    professors = professors_collection.find({}, {"_id": 0, "name": 1})
    professor_list = [prof["name"] for prof in professors]
    return JSONResponse(content={"professors": professor_list}, media_type="application/json; charset=utf-8")

@app.get("/assistants")
def get_assistants():
    assistants = assistants_collection.find({}, {"_id": 0, "name": 1})
    assistant_list = [assistant["name"] for assistant in assistants]
    return JSONResponse(content={"assistants": assistant_list}, media_type="application/json; charset=utf-8")

class Comment(BaseModel):
    comment: str
    time: str  # Ensure that FastAPI automatically parses the ISO string

@app.post("/comments/{entity_type}/{entity_name}")
def add_comment(entity_type: str, entity_name: str, comment: dict):
    # Validate entity_type
    print(comment)
    if entity_type not in ["course", "professor", "assistant"]:
        raise HTTPException(status_code=400, detail="Invalid entity type")

    # Upsert operation: Update if exists, insert if not
    comments_collection.update_one(
        {"entity_type": entity_type, "entity_name": entity_name},  # Query
        {
            "$push": {"comments": comment},  # Append to the "comment" array
            "$setOnInsert": {  # Set these fields only on insert
                "entity_type": entity_type,
                "entity_name": entity_name,
            }
        },
        upsert=True  # Perform an upsert
    )

    return {"message": "Comment added successfully"}

@app.get("/comments/{entity_type}/{entity_name}")
def get_comments(entity_type: str, entity_name: str):
    if entity_type not in ["course", "professor", "assistant"]:
        raise HTTPException(status_code=400, detail="Invalid entity type")
    comments = comments_collection.find_one({"entity_type": entity_type, "entity_name": entity_name}, {"_id": 0, "comments": 1})
    if comments is None:
        return []
    return comments.get("comments", [])

@app.get("/get_rooms")
def get_rooms():
    rooms_object = rooms.find_one({}, {"_id": 0})
    formatted_rooms_dict = {}
    for key, values in rooms_object.items():
        temp_list = []
        for point in values:
            temp_list.append({
                "name": point.get("name"),
                "location": {
                    "latitude": point.get("location").get("coordinates")[1],
                    "longitude": point.get("location").get("coordinates")[0],
                },
                "info": point.get("info")
            })
        formatted_rooms_dict[key] = temp_list
    print(formatted_rooms_dict)
    return JSONResponse(content=formatted_rooms_dict, media_type="application/json; charset=utf-8")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
