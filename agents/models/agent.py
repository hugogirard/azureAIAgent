from typing import List
from pydantic import BaseModel

class AgentConfiguration(BaseModel):
    name: str
    model: str
    description: str
    instruction: str
    tools: list    