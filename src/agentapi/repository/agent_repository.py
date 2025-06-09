from azure.cosmos.aio import ContainerProxy
from models.agent import Agent
from typing import List

class AgentRepository:

    def __init__(self,container: ContainerProxy):
        self.container = container

    async def all(self) -> List[Agent]:
        agents = []
        query = "SELECT * FROM c"
        async for item in self.container.query_items(query=query):
            agent = Agent.model_validate(item)
            agents.append(agent)
        return agents             