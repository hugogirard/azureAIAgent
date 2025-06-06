from pydantic import BaseModel

class Agent(BaseModel):
    id: str
    name: str