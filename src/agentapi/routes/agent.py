from fastapi import APIRouter, Depends, HTTPException
from dependencies import get_agent_repository, get_thread_repository, get_logger, get_project_client
from repository import AgentRepository, ThreadRepository
from azure.ai.projects.aio import AIProjectClient
from typing import Annotated, List
from models.agent import Agent
from logging import Logger

router = APIRouter(
    prefix="/agent"
)

@router.get('/all')
async def all(agent_repository: Annotated[AgentRepository, Depends(get_agent_repository)]) -> List[Agent]:
    return await agent_repository.all()


# @router.delete("/reset/factory",description="Delete all agents and threads in the system")
# async def reset_factory(agent_repository: Annotated[AgentRepository, Depends(get_agent_repository)],
#                         thread_repository: Annotated[ThreadRepository, Depends(get_thread_repository)],
#                         project_client: Annotated[AIProjectClient, Depends(get_project_client)],
#                         logger: Annotated[Logger, Depends(get_logger)],):
#     try:

#       agents = project_client.agents.list_agents()

#       async for agent in agents:
#          await project_client.agents.delete_agent(agent.id)

#       agent_repository.delete_all()   

#     except Exception as err:
#       logger.error(err)
#       raise HTTPException(status_code=500, detail='Internal Server Error')   