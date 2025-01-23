import requests
from bs4 import BeautifulSoup
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pymongo import MongoClient
from typing import List
import os
from dotenv import load_dotenv


load_dotenv()
CONNECTION_STRING = os.getenv("CONNECTION_STRING")

client = MongoClient(CONNECTION_STRING)
db = client["finki_data"]
courses_collection = db["courses"]
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
    return {"courses": [course["name"] for course in courses]}

@app.get("/professors")
def get_professors():
    professors = professors_collection.find({}, {"_id": 0, "name": 1})
    return {"professors": [prof["name"] for prof in professors]}

@app.get("/assistants")
def get_assistants():
    assistants = assistants_collection.find({}, {"_id": 0, "name": 1})
    return {"assistants": [assistant["name"] for assistant in assistants]}

class Comment(BaseModel):
    comment: str

@app.post("/comments/{entity_type}/{entity_name}")
def add_comment(entity_type: str, entity_name: str, comment: Comment):
    if entity_type not in ["course", "professor", "assistant"]:
        raise HTTPException(status_code=400, detail="Invalid entity type")
    comments_collection.insert_one({
        "entity_type": entity_type,
        "entity_name": entity_name,
        "comment": comment.comment
    })
    return {"message": "Comment added successfully"}

@app.get("/comments/{entity_type}/{entity_name}")
def get_comments(entity_type: str, entity_name: str):
    if entity_type not in ["course", "professor", "assistant"]:
        raise HTTPException(status_code=400, detail="Invalid entity type")
    comments = comments_collection.find({"entity_type": entity_type, "entity_name": entity_name}, {"_id": 0, "comment": 1})
    return {"comments": [comment["comment"] for comment in comments]}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
