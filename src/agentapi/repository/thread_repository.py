from azure.cosmos.aio import ContainerProxy
from models.thread import Thread
from typing import List

class ThreadRepository:

    def __init__(self,container: ContainerProxy):
        self.container = container

    async def insert(self,thread:Thread) -> None:
        await self.container.create_item(thread.model_dump())

    async def get(self,username:str) -> List[Thread]:
        threads = []
        query = "SELECT * FROM c WHERE c.username = @username"
        async for item in self.container.query_items(query=query,
                                                     parameters=[{"name": "@username", "value": username}]):
            thread = Thread.model_validate(item)
            threads.append(thread)

        return threads
            
    async def delete(self, id:str, username: str) -> None:
        query = "SELECT * c WHERE c.id = @id AND c.username = @username"
        thread = None
        async for item in self.container.query_items(query=query,
                                                     parameters=[{"name": "@id", "value": id},
                                                                 {"name": "@username", "value": username}]):
            thread = Thread.model_validate(item)        

        if thread is None:
            return
        
        await self.container.delete_item(item, partition_key=username)