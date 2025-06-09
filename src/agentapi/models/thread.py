from pydantic import BaseModel

class Thread(BaseModel):
    id: str
    username: str