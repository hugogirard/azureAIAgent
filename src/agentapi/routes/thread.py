from fastapi import APIRouter, Depends,HTTPException
from typing import Annotated, Dict, List
from models import (Thread, Message)
from repository.thread_repository import ThreadRepository
from azure.ai.projects.aio import AIProjectClient
from azure.ai.agents.models import ThreadMessage, MessageRole, RunStatus
from request.new_message import NewMessage
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

@router.get("/")
async def get_thread(thread_id: str,
                     agent_id: str,
                     logger: Annotated[Logger, Depends(get_logger)],
                     project_client: Annotated[AIProjectClient, Depends(get_project_client)]) -> List[Message]:
    try: 
      messages = project_client.agents.messages.list(thread_id)
      formatted_messages = []            
      async for message in messages:        
        annotation_content = _get_message_and_annotations(message)                
        formatted_message = Message(
           id=message.id,        
           agent_id=agent_id,
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
                          thread_repository: Annotated[ThreadRepository, Depends(get_thread_repository)],
                          logger: Annotated[Logger, Depends(get_logger)]) -> List[str]:
    
   try:
   
     threads = await thread_repository.get(user_principal_name)
     return [thread.id for thread in threads]          
   
   except Exception as err:
     logger.error(err)
     raise HTTPException(status_code=500, detail='Internal Server Error') 

@router.post("/{agent_id}")
async def new_thread(agent_id: str,
                     user_principal_name: Annotated[str, Depends(get_easy_auth_token)],                     
                     project_client: Annotated[AIProjectClient, Depends(get_project_client)],
                     thread_repository: Annotated[ThreadRepository, Depends(get_thread_repository)],
                     logger: Annotated[Logger, Depends(get_logger)]) -> str:
    
   try:     
     
     # Set the agent to use for this thread
     await project_client.agents.get_agent(agent_id)

     thread = await project_client.agents.threads.create()

     await thread_repository.insert(Thread(
        id=thread.id,
        username=user_principal_name
     ))

     return thread.id
   
   except Exception as err:
     logger.error(err)
     raise HTTPException(status_code=500, detail='Internal Server Error')          
   
@router.post("/message")
async def new_message(user_principal_name: Annotated[str, Depends(get_easy_auth_token)],
                      new_message:NewMessage,
                      project_client: Annotated[AIProjectClient, Depends(get_project_client)],
                      thread_repository: Annotated[ThreadRepository, Depends(get_thread_repository)],
                      logger: Annotated[Logger, Depends(get_logger)]) -> str:
   try:

      message = project_client.agents.messages.create(
         thread_id=new_message.thread_id,
         role=MessageRole.USER,
         content=new_message.prompt
      )

      run = await project_client.agents.runs.create_and_process(thread_id=new_message.thread_id,
                                                                agent_id=new_message.agent_id)
      
      if run.status == RunStatus.FAILED:
         logger.error(f"Run status failed: ${run.last_error.message}")
         raise HTTPException(status_code=500, detail='Internal Server Error')              

   except Exception as err:
     logger.error(err)
     raise HTTPException(status_code=500, detail='Internal Server Error')            

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