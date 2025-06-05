import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from models.agent import AgentConfiguration
from typing import List
import json

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

with open("agent.configuration.json","r") as f:
    configuration = json.load(f)

# Get all agents
azure_agents = []

for azure_agent in project_client.agents.list_agents(): 
    azure_agents.append({
        "id": azure_agent.id,
        "name": azure_agent.name
    })

agents: List[AgentConfiguration] = [AgentConfiguration(**entry) for entry in configuration]

for agent in agents:        
   # Find existing agent by name
    existing_agent = next((a for a in azure_agents if a["name"] == agent.name), None)

    if existing_agent:
        if overwrite:
            print(f"Agent {agent.name} will be updated")
            created_agent = project_client.agents.update_agent(
                agent_id=existing_agent["id"],
                model=agent.model,
                name=agent.name,
                description=agent.description,
                instruction=agent.description
            )
            print(f"Agent ${agent.name} created with ID: ${created_agent.id}")            
            pass
        else:    
            print(f"Agent {agent.name} already exists. Skipping creation.")            
    else:
        created_agent = project_client.agents.create_agent(
            model=agent.model,
            name=agent.name,
            description=agent.description,
            instruction=agent.description
        )
        print(f"Agent ${agent.name} created with ID: ${created_agent.id}")