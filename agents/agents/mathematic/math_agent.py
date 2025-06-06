import uuid
from ..agent_configuration import BaseAgent
from models.agent import AgentConfiguration
from azure.ai.agents.models import CodeInterpreterTool
from azure.ai.projects.models import Connection
from typing import List

class MathAgent(BaseAgent):

    def get_agent(connections: List[Connection]) -> AgentConfiguration:
       code_interpreter = CodeInterpreterTool()
       return AgentConfiguration(
           name="MathematicalAgent",
           description="This agent run python code to solve math problems",
           instruction=("You are a mathematical agent, you write python code to execute mathematical question. "
                        "If the question is not mathematical related you answer: This is not mathematical question related." \
                        "You ALWAYS show the Python Code you wrote to resolve the equation and after you gave the answer"),
           model="gpt-4o",
           tools=code_interpreter.definitions
       )