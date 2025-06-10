from ..multi_agent_configuration import BaseMainAgent
from typing import Dict
from models.agent import AgentConfiguration
from azure.ai.agents.models import ConnectedAgentTool

class MainStockAgent(BaseMainAgent):
  
  def get_agent(agents: Dict[str,str]) -> AgentConfiguration:

    connected_agent = None

    for agent in agents:        
        if agent["name"] == "StockAgent":
            connected_agent = agent
            break

    if connected_agent is None:
       return
    
    connected_agent = ConnectedAgentTool(
        id=connected_agent['id'], 
        name=connected_agent['name'], 
        description="Gets the stock price of a company"
    )    

    return AgentConfiguration(
      name="MultiAgentMarket",
      description="Multi Agent Market",
      instruction=("You are a helpful agent, and use the available tools to get stock prices."),
      model="gpt-4o",
      tools=connected_agent.definitions
    )

        