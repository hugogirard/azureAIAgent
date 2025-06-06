from dotenv import load_dotenv
import os

load_dotenv(override=True)

class Config:
   
   @staticmethod
   def cosmosdb_endpoint() -> str:
     return os.getenv('COSMOS_ENDPOINT')
   
   @staticmethod
   def cosmos_database() -> str:
     return os.getenv('COSMOS_DATABASE')    
   
   @staticmethod   
   def thread_cosmos_container() -> str:
     return os.getenv('COSMOS_THREAD_CONTAINER')
   
   @staticmethod   
   def agent_cosmos_container() -> str:
     return os.getenv('COSMOS_AGENT_CONTAINER')
   
   @staticmethod
   def project_endpoint() -> str:
     return os.getenv('PROJECT_ENDPOINT')   
   
   @staticmethod
   def is_development() -> bool:
      value = os.getenv('IS_DEVELOPMENT', 'false').lower()
      return value in ['true', '1', 'yes']
   
   @staticmethod
   def user_principal_name_dev() -> str:
      return os.getenv('USER_PRINCIPAL_NAME','')