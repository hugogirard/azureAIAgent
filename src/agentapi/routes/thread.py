from fastapi import APIRouter, Depends,HTTPException
from typing import Annotated, Dict, List
from models import (Agent, Message)
from repository.thread_repository import ThreadRepository
from azure.ai.projects.aio import AIProjectClient
from azure.ai.agents.aio import AgentsClient
from azure.ai.agents.models import ThreadMessage
from logging import Logger
from dependencies import (
   get_thread_repository, 
   get_easy_auth_token, 
   get_project_client,
   get_logger
)

router = APIRouter(
    prefix="/thread"
)

@router.get("/{id}")
async def get_thread(id: str,
                     logger: Annotated[Logger, Depends(get_logger)],
                     project_client: Annotated[AIProjectClient, Depends(get_project_client)]) -> List[Message]:
    try:
      #agent_thread = await project_client.agents.threads.get(id)
      messages = project_client.agents.messages.list(id)
      formatted_messages = []
      async for message in messages:
        annotation_content = _get_message_and_annotations(message)
        formatted_message = Message(
           id=message.id,
           content=annotation_content['content'],
           annotations=annotation_content['annotations'],
           created_at=message.created_at.astimezone().strftime("%m/%d/%y, %I:%M %p"),  
           role=message.role
        )
        formatted_messages.append(formatted_message)
      
      return formatted_messages
    except Exception as err:
      logger.error(err)
      raise HTTPException(status_code=500, detail='Internal Server Error')   


@router.get("/all")
async def get_all_threads(user_principal_name: Annotated[str, Depends(get_easy_auth_token)],
                          thread_repository: Annotated[ThreadRepository, Depends(get_thread_repository)]) -> List[str]:
    
    threads = await thread_repository.get(user_principal_name)
    return [thread.id for thread in threads]

@router.post("/")
async def new_thread() -> str:
    pass

@router.post("/message")
async def new_message() -> str:
    pass

def _get_message_and_annotations(message: ThreadMessage) -> Dict:
   annotations = []

   # Get file annotations for the file search
   # No agent using this now
#    for annotation in (a.as_dict() for a in message.file_citation_annotations):
#      file_id = annotation["file_citation"]["file_id"]    
#      file_info = await agent_client.files.get(file_id)
#      annotation["file_name"] = file_info.filename
#      annotations.append(annotation)   

   # Get url annotation for the index search if your agent connect to Azure AI Search.
   for url_annotation in message.url_citation_annotations:
      annotation = url_annotation.as_dict()
      annotation["file_name"] = annotation['url_citation']['title']   
      annotations.append(annotation)

   return {
     'content': message.text_messages[0].text.value,
     'annotations': annotations
   }      