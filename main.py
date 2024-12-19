from pathlib import Path
from typing import Annotated
from uuid import uuid4
from slugify import slugify

from fastapi import FastAPI, Form
from fastapi.responses import JSONResponse, Response

app = FastAPI()

data_dir = Path("./data")
data_dir.mkdir(exist_ok=True)

@app.post("/todos/")
def create_todo(message: Annotated[str, Form()], title: Annotated[str, Form()]):
    todo_id = slugify(title)
    
    todo_path = data_dir / todo_id
    with todo_path.with_suffix('.md').open("w") as file:
        file.write(message)
    
    location_url = f"/todos/{todo_id}"
    response = JSONResponse(content={"id": todo_id}, status_code=201)
    response.headers["Location"] = location_url
    return response

@app.get("/healthcheck")
def healthcheck():
    return Response(status_code=200)
