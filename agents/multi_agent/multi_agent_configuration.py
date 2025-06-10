from abc import ABC, abstractmethod
from models.agent import AgentConfiguration
from azure.ai.projects.models import Connection
from typing import Dict, List

class BaseMainAgent(ABC):
    
    @abstractmethod
    def get_agent(agents: Dict[str,str]) -> AgentConfiguration:
        pass