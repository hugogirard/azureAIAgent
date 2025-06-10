from dataclasses import dataclass, field
from typing import Dict, Optional
from .agent import AgentConfiguration

@dataclass
class MainAgent(AgentConfiguration):
    """
    This is the main class to configure
    multi agents
    """    

    # The name of the connected agent
    connected_agent: str