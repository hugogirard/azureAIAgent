import os
from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import Connection
from azure.identity import DefaultAzureCredential
from models.agent import AgentConfiguration
from typing import List
from utility import Utility
from dotenv import load_dotenv
from services.agent_repository import AgentRepository

load_dotenv(override=True)

agent_repository = AgentRepository()

# Be sure the environment variable is set in the GitHub repository
project_endpoint = os.environ["PROJECT_ENDPOINT"]

overwrite: bool = os.getenv('OVERWRITE', 'false').lower() == 'true'

print(f"Overwrite mode set to : {overwrite}")

# Create an AIProjectClient instance
project_client = AIProjectClient(
    endpoint=project_endpoint,
    credential=DefaultAzureCredential(),  # Use Azure Default Credential for authentication
    api_version="v1",
)

connection: List[Connection] = project_client.connections.list()

print("Load existing Azure configured agents")

# Get all agents
azure_agents = []

for azure_agent in project_client.agents.list_agents(): 
    azure_agents.append({
        "id": azure_agent.id,
        "name": azure_agent.name
    })

print(f"Found {len(azure_agents)} existing agents")

base_agents_dir = os.path.join(os.path.dirname(__file__), "agents")
agents = Utility.find_agent_classes(base_agents_dir)

print(f"Found {len(agents)} agents")

agents_configuration: List[AgentConfiguration] = []

for agent in agents:
    configuration: AgentConfiguration = agent.get_agent(connection)
    agents_configuration.append(configuration)
    
Utility.upsert_agents(
    overwrite,
    agents_configuration,
    azure_agents,
    project_client,
    agent_repository
)

print("Reload list of added/updated agents")

azure_agents = []
for azure_agent in project_client.agents.list_agents(): 
    azure_agents.append({
        "id": azure_agent.id,
        "name": azure_agent.name
    })

base_agents_dir = os.path.join(os.path.dirname(__file__), "multi_agent")
agents = Utility.find_multi_agent_classes(base_agents_dir)

print(f"Found {len(agents)} multi-agents")

agents_configuration: List[AgentConfiguration] = []

for agent in agents:
    configuration: AgentConfiguration = agent.get_agent(azure_agents)
    agents_configuration.append(configuration)

Utility.upsert_agents(
    overwrite,
    agents_configuration,
    azure_agents,
    project_client,
    agent_repository
)    