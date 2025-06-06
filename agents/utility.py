from typing import List
from agents.agent_configuration import BaseAgent
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
