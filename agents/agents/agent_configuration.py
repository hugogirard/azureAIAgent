from abc import ABC, abstractmethod
from models.agent import AgentConfiguration
from azure.ai.projects.models import Connection
from typing import List

class BaseAgent(ABC):
    
    @abstractmethod
    def get_agent(connections: List[Connection]) -> AgentConfiguration:
        pass