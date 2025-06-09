from datetime import datetime
from pydantic import BaseModel
from typing import Optional, List, Any

class Message(BaseModel):
    id: str
    content: str
    annotations: Optional[List[Any]] = None
    created_at: str    
    role: str