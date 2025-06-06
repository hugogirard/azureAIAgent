import os
from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import Connection
from azure.identity import DefaultAzureCredential
from models.agent import AgentConfiguration
from typing import List
from utility import Utility
from dotenv import load_dotenv

load_dotenv(override=True)

# Be sure the environment variable is set in the GitHub repository
project_endpoint = os.environ["PROJECT_ENDPOINT"]

overwrite: bool = os.getenv('OVERWRITE', 'false').lower() == 'true'

print(f"Overwrite mode set to : ${overwrite}")

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

print(f"Found ${len(azure_agents)} existing agents")

base_agents_dir = os.path.join(os.path.dirname(__file__), "agents")
agents = Utility.find_agent_classes(base_agents_dir)

print(f"Found {len(agents)} agents")

agents_configuration: List[AgentConfiguration] = []

for agent in agents:
    configuration: AgentConfiguration = agent.get_agent(connection)
    agents_configuration.append(configuration)
    

for agent_conf in agents_configuration:        
   # Find existing agent by name
    existing_agent = next((a for a in azure_agents if a["name"] == agent_conf.name), None)

    if existing_agent:
        if overwrite:
            print(f"Agent {agent_conf.name} will be updated")
            created_agent = project_client.agents.update_agent(
                agent_id=existing_agent["id"],
                model=agent_conf.model,
                name=agent_conf.name,
                description=agent_conf.description,
                instructions=agent_conf.description,
                tools=agent_conf.tools,
                tool_resources=agent_conf.tool_resource

            )
            print(f"Agent ${agent.name} created with ID: ${created_agent.id}")            
            pass
        else:    
            print(f"Agent {agent.name} already exists. Skipping creation.")            
    else:
        created_agent = project_client.agents.create_agent(
            model=agent_conf.model,
            name=agent_conf.name,
            description=agent_conf.description,
            instructions=agent_conf.instruction,
            tools=agent_conf.tools,
            tool_resources=agent_conf.tool_resource     
        )
        print(f"Agent ${agent_conf.name} created with ID: ${created_agent.id}")