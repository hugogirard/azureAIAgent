from typing import Dict, List
from agents.agent_configuration import BaseAgent
from models.agent import AgentConfiguration
from multi_agent.multi_agent_configuration import BaseMainAgent
from azure.ai.projects import AIProjectClient
from services.agent_repository import AgentRepository
import os
import importlib
import inspect

class Utility:

    @staticmethod
    def find_agent_classes(base_dir) -> List[BaseAgent]:        
        agent_classes = []
        for root, dirs, files in os.walk(base_dir):
            for file in files:
                if file.endswith(".py") and not file.startswith("__"):
                    module_path = os.path.relpath(os.path.join(root, file), os.path.dirname(__file__))
                    module_name = module_path[:-3].replace(os.sep, ".")
                    try:
                        module = importlib.import_module(module_name)
                        for name, obj in inspect.getmembers(module, inspect.isclass):
                            if issubclass(obj, BaseAgent) and obj is not BaseAgent:
                                agent_classes.append(obj)
                    except Exception as e:
                        print(f"Failed to import {module_name}: {e}")
        return agent_classes    
    
    @staticmethod
    def find_multi_agent_classes(base_dir) -> List[BaseMainAgent]:        
        agent_classes = []
        for root, dirs, files in os.walk(base_dir):
            for file in files:
                if file.endswith(".py") and not file.startswith("__"):
                    module_path = os.path.relpath(os.path.join(root, file), os.path.dirname(__file__))
                    module_name = module_path[:-3].replace(os.sep, ".")
                    try:
                        module = importlib.import_module(module_name)
                        for name, obj in inspect.getmembers(module, inspect.isclass):
                            if issubclass(obj, BaseMainAgent) and obj is not BaseMainAgent:
                                agent_classes.append(obj)
                    except Exception as e:
                        print(f"Failed to import {module_name}: {e}")
        return agent_classes    

    @staticmethod
    def upsert_agents(overwrite: bool,
                      agents_configuration: List[AgentConfiguration],
                      azure_agents: Dict[str,str],
                      project_client: AIProjectClient,
                      agent_repository: AgentRepository):
      for agent_conf in agents_configuration:        
        # Find existing agent by name
        existing_agent = next((a for a in azure_agents if a["name"] == agent_conf.name), None)
        agent_id: str = None
        update_agent: bool = False

        if existing_agent:
          if overwrite:
            print(f"Agent {agent_conf.name} will be updated")
            created_agent = project_client.agents.update_agent(
                agent_id=existing_agent["id"],
                model=agent_conf.model,
                name=agent_conf.name,
                description=agent_conf.description,
                instructions=agent_conf.instruction,
                tools=agent_conf.tools,
                tool_resources=agent_conf.tool_resource

            )
            print(f"Agent ${agent_conf.name} created with ID: ${created_agent.id}")     
            update_agent = True
            agent_id = created_agent.id
            pass
          else:    
            print(f"Agent {agent_conf.name} already exists. Skipping creation.")            
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
          update_agent = True
          agent_id = created_agent.id

        if update_agent:
          update_agent = False
          agent_repository.upsert_agent(agent_conf.name,agent_id)