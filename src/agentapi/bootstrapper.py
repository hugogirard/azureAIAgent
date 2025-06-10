from fastapi import FastAPI, Request
from contextlib import asynccontextmanager
from azure.identity.aio import DefaultAzureCredential
from azure.ai.projects.aio import AIProjectClient
from azure.cosmos.aio import CosmosClient
from azure.monitor.opentelemetry import configure_azure_monitor
from fastapi.responses import JSONResponse
from config import Config
from repository import (
    AgentRepository,
    ThreadRepository
)
import logging
import sys

@asynccontextmanager
async def lifespan_event(app: FastAPI):
    
    credential = DefaultAzureCredential()
    cosmos_client = CosmosClient(url=Config.cosmosdb_endpoint(), 
                                 credential=credential)    
    
    db = cosmos_client.get_database_client(Config.cosmos_database())

    app.state.agent_repository = AgentRepository(db.get_container_client(Config.agent_cosmos_container()))    

    app.state.thread_repository = ThreadRepository(db.get_container_client(Config.thread_cosmos_container()))

    project_client = AIProjectClient(
        endpoint=Config.project_endpoint(),
        credential=credential,
        api_version="v1" # Important find the version here --> https://learn.microsoft.com/en-us/rest/api/aifoundry/aiagents/operation-groups?view=rest-aifoundry-aiagents-v1
    )

    # Configure the project client needed to use Agent
    app.state.project_client = project_client

    # Now we configure the monitoring
    # We don't want to fail if something
    # goes wrong here
    try:
       application_insight_cnxstring = await project_client.telemetry.get_connection_string()
       configure_azure_monitor(connection_string=application_insight_cnxstring)
    except Exception as err:
        pass

    # Configure logger    
    app.state.logger = logging.getLogger('chatapi')

    if Config.is_development():
        app.state.logger.setLevel(logging.DEBUG)
    else:
        app.state.logger.setLevel(logging.INFO)

    # StreamHandler for the console
    stream_handler = logging.StreamHandler(sys.stdout)
    log_formatter = logging.Formatter("%(asctime)s [%(processName)s: %(process)d] [%(threadName)s: %(thread)d] [%(levelname)s] %(name)s: %(message)s")
    stream_handler.setFormatter(log_formatter)
    app.state.logger.addHandler(stream_handler)    

    yield
    

class Bootstrapper:

    def run(self) -> FastAPI:

        app = FastAPI(lifespan=lifespan_event,
                      title="Contoso Agent API",
                      version="1.0",
                      summary="Api showing the Power of Azure AI Agent with FastAPI and Azure AI Foundry")

        # Global exception handler for any unhandled exceptions
        @app.exception_handler(Exception)
        async def global_exception_handler(request: Request, exc: Exception):
            request.app.state.logger("Unhandled exception occurred", exc_info=exc)
            return JSONResponse(
                status_code=500,
                content={"detail": "Internal server error"}
            )

        return app
