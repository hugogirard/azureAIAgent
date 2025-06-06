from fastapi import FastAPI
from contextlib import asynccontextmanager
from azure.identity.aio import DefaultAzureCredential
from azure.cosmos.aio import CosmosClient
from config import Config
from repository import (
    AgentRepository
)

@asynccontextmanager
async def lifespan_event(app: FastAPI):
    
    credential = DefaultAzureCredential()
    cosmos_client = CosmosClient(url=Config.cosmosdb_endpoint(), 
                                 credential=credential)    
    
    db = cosmos_client.get_database_client(Config.cosmos_database())

    app.state.agent_repository = AgentRepository(db.get_container_client(Config.agent_cosmos_container()))    

    yield
    

class Bootstrapper:

    def run(self) -> FastAPI:

        app = FastAPI(lifespan=lifespan_event)
     
        self._configure_monitoring(app)

        return app
     
    def _configure_monitoring(self, app: FastAPI):
        pass