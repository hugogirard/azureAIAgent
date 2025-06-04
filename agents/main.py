import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from models.agent import AgentConfiguration
from typing import List
import json

# Be sure the environment variable is set in the GitHub repository
project_endpoint = os.environ["PROJECT_ENDPOINT"]

# Create an AIProjectClient instance
project_client = AIProjectClient(
    endpoint=project_endpoint,
    credential=DefaultAzureCredential(),  # Use Azure Default Credential for authentication
    api_version="v1",
)

with open("agent.configuration.json","r") as f:
    configuration = json.load(f)

agents: List[AgentConfiguration] = [AgentConfiguration(**entry) for entry in configuration]

for agent in agents:
    print(agent.name)