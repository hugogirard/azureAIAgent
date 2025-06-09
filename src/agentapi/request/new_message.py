from pydantic import BaseModel, Field


class NewMessage(BaseModel):
    thread_id:str = Field(default=None, alias="threadId") 
    agent_id:str = Field(default=None, alias="agentId")
    prompt:str