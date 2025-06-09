from .agent import router as agent_router
from .thread import router as thread_router

routes = [
    agent_router,
    thread_router
]