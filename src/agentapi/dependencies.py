from config import Config
from fastapi import Request, HTTPException
from repository import (
    AgentRepository
)

# This should be set during development mode
# it's easier but you could always inject the
# X-MS-CLIENT-PRINCIPAL-NAME Header
_isDevelopment = Config.is_development()
_user_principal_name = Config.user_principal_name_dev()

def get_agent_repository(request: Request) -> AgentRepository:
    return request.app.state.agent_repository

def get_easy_auth_token(request: Request)->str:
    if _isDevelopment:
        user_principal_id = _user_principal_name
    else:
        user_principal_id = request.headers.get(key='X-MS-CLIENT-PRINCIPAL-NAME',default=None)
    
    if user_principal_id is None:
        raise HTTPException(401,'No user identity present')
    
    return user_principal_id