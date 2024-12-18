from pathlib import Path
from typing import Annotated
from uuid import uuid4

from fastapi import FastAPI, Form, HTTPException
from fastapi.responses import JSONResponse

app = FastAPI()

data_dir = Path("./data")
data_dir.mkdir(exist_ok=True)

@app.post("/todos/", status_code=201)
def create_todo(message: Annotated[str, Form()]):
    todo_id = str(uuid4())
    
    todo_path = data_dir / todo_id
    with todo_path.open("w") as file:
        file.write(message)
    
    location_url = f"/todos/{todo_id}"
    response = JSONResponse(content={"id": todo_id})
    response.headers["Location"] = location_url
    return response
