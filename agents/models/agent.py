from dataclasses import dataclass, field
from typing import Dict, Optional

@dataclass
class AgentConfiguration:
    name: str
    model: str
    description: str
    instruction: str
    tool_resource: Optional[any] = None
    tools: Optional[any] = None
    temperature: Optional[float] = None
    top_p: Optional[float] = None
    metadata: Optional[Dict[str, str]] = field(default_factory=dict)