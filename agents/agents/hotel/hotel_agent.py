import uuid
from ..agent_configuration import BaseAgent
from models.agent import AgentConfiguration
from azure.ai.projects.models import Connection, ConnectionType
from azure.ai.agents.models import AzureAISearchTool, AzureAISearchQueryType
from typing import List
import os

class HotelAgent(BaseAgent):

    def get_agent(connections: List[Connection]) -> AgentConfiguration:
       
       connection_id: str = None

       for connection in connections:
           # If you have multiple AI Search connection in your AI Foundry, you 
           # will need to find by name or other
           if connection.type == ConnectionType.AZURE_AI_SEARCH:
               connection_id = connection.id
               break
       
       index_name = os.getenv('HOTEL_INDEX_NAME')

        # Initialize the Azure AI Search tool
       ai_search = AzureAISearchTool(
           index_connection_id=connection_id,
           index_name=index_name,
           query_type=AzureAISearchQueryType.SIMPLE,
           top_k=5,
           filter=""
       )

       return AgentConfiguration(
           name="HotelReviewAgent",
           description="This agent look hotel reviews",
           instruction=("You are an hotel assistant use only the knowledge data you have from the hotels index.  "
                        "You always speak like Sheldon from the big bang theory"),
           model="gpt-4o",
           tools=ai_search.definitions,
           tool_resource=ai_search.resources        
       )