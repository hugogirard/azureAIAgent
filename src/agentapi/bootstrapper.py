from fastapi import FastAPI
from contextlib import asynccontextmanager
from azure.identity.aio import DefaultAzureCredential
from azure.ai.projects.aio import AIProjectClient
from azure.cosmos.aio import CosmosClient
from config import Config
from repository import (
    AgentRepository,
    ThreadRepository
)

@asynccontextmanager
async def lifespan_event(app: FastAPI):
    
    credential = DefaultAzureCredential()
    cosmos_client = CosmosClient(url=Config.cosmosdb_endpoint(), 
                                 credential=credential)    
    
    db = cosmos_client.get_database_client(Config.cosmos_database())

    app.state.agent_repository = AgentRepository(db.get_container_client(Config.agent_cosmos_container()))    

    app.state.thread_repository = ThreadRepository(db.get_container_client(Config.thread_cosmos_container()))

    # Configure the project client needed to use Agent
    app.state.project_client = AIProjectClient(
        endpoint=Config.project_endpoint(),
        credential=credential,
        api_version="v1" # Important find the version here --> https://learn.microsoft.com/en-us/rest/api/aifoundry/aiagents/operation-groups?view=rest-aifoundry-aiagents-v1
    )

    yield
    

class Bootstrapper:

    def run(self) -> FastAPI:

        app = FastAPI(lifespan=lifespan_event,
                      title="Contoso Agent API",
                      version="1.0",
                      summary="Api showing the Power of Azure AI Agent with FastAPI and Azure AI Foundry")
     
        self._configure_monitoring(app)

        return app
     
    def _configure_monitoring(self, app: FastAPI):
        pass