from ..agent_configuration import BaseAgent
from models.agent import AgentConfiguration
from azure.ai.agents.models import CodeInterpreterTool
from azure.ai.projects.models import Connection
from azure.ai.agents.models import OpenApiTool, OpenApiAnonymousAuthDetails
from typing import List
import os
import requests

class TamrielAgent(BaseAgent):

    def get_agent(connections: List[Connection]) -> AgentConfiguration:
       
       openapi_url = os.getenv('WEATHER_API_URL_OPENAI')
       response = requests.get(openapi_url)
       openapi_json = response.json()       
       auth = OpenApiAnonymousAuthDetails()

       openapi_tool = OpenApiTool(name="get_tamriel_weather",
                                  spec=openapi_json,
                                  description="Weather From Tamriel",
                                  auth=auth)

       return AgentConfiguration(
           name="TamrielAgent",
           description="This agent return the Weather from Tamriel",
           instruction=("Your are a weather assistant for Tamriel Weather.  Use the tool you have"),
           model="gpt-4o",
           tools=openapi_tool.definitions
       )