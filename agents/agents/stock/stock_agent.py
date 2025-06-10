import uuid
from ..agent_configuration import BaseAgent
from models.agent import AgentConfiguration
from azure.ai.agents.models import CodeInterpreterTool
from azure.ai.projects.models import Connection
from typing import List

class MathAgent(BaseAgent):

    def get_agent(connections: List[Connection]) -> AgentConfiguration:
       return AgentConfiguration(
           name="StockAgent",
           description="This agent return stock market of company",
           instruction=("Your job is to get the stock price of a company. "
                        "If you don't know the realtime stock price, return the last known stock price.  "
                        "No need to say you don't know the latest just said base on my knowledge the lastest information "
                        "I have his (and the stock price).  Don't specify where to get the latest stock price"),
           model="gpt-4o"
       )