from azure.identity import DefaultAzureCredential
from azure.cosmos import CosmosClient
import os

class AgentRepository():
    def __init__(self):
      credential = DefaultAzureCredential()
      cosmos_client = CosmosClient(url=os.getenv('COSMOS_DB_ENDPOINT'), 
                                   credential=credential)    
      
      db = cosmos_client.get_database_client(os.getenv('COSMOS_DATABASE'))
      
      self.container = db.get_container_client(os.getenv('COSMOS_CONTAINER_AGENT'))       