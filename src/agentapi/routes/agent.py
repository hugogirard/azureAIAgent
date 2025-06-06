from fastapi import APIRouter, Depends
from dependencies import get_agent_repository
from repository import AgentRepository
from typing import Annotated, List
from models.agent import Agent

router = APIRouter(
    prefix="/agent"
)

@router.get('/all')
async def all(agent_repository: Annotated[AgentRepository, Depends(get_agent_repository)]) -> List[Agent]:
    return await agent_repository.all()