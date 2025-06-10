from config import Config
from fastapi import Request, HTTPException
from azure.ai.projects.aio import AIProjectClient
from repository import (
    AgentRepository,
    ThreadRepository
)
from logging import Logger
import logging
import sys

# This should be set during development mode
# it's easier but you could always inject the
# X-MS-CLIENT-PRINCIPAL-NAME Header
_user_principal_name = Config.user_principal_name_dev()

def get_agent_repository(request: Request) -> AgentRepository:
    return request.app.state.agent_repository

def get_thread_repository(request: Request) -> ThreadRepository:
    return request.app.state.thread_repository

def get_project_client(request: Request)-> AIProjectClient:
    return request.app.state.project_client

def get_easy_auth_token(request: Request)->str:
    if Config.is_development():
        user_principal_id = _user_principal_name
    else:
        user_principal_id = request.headers.get(key='X-MS-CLIENT-PRINCIPAL-NAME',default=None)
    
    if user_principal_id is None:
        raise HTTPException(401,'No user identity present')
    
    return user_principal_id

def get_logger(request: Request) -> Logger:
    return request.app.state.logger