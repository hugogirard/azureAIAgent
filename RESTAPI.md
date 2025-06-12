# 🤖 AgentAPI – REST API for Azure AI Agentic Framework

AgentAPI is a FastAPI-based REST service that orchestrates agent and thread management using the Azure AI SDK and Cosmos DB. It provides endpoints for creating, updating, and querying agents and their conversational threads, leveraging Azure’s secure identity and observability features.

---

## 🏗️ Architecture Overview

- **Framework:** [FastAPI](https://fastapi.tiangolo.com/)
- **Azure Integration:**  
  - [Azure AI Foundry SDK](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/develop/sdk-overview?pivots=programming-language-python)
  - [Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/introduction)
  - [Azure Identity](https://learn.microsoft.com/en-us/python/api/overview/azure/identity-readme)

- **Key Modules:**
  - `models/`: Pydantic models for agents, threads, and messages
  - `repository/`: Data access layers for Cosmos DB
  - `routes/`: FastAPI routers for REST endpoints
  - `dependencies.py`: Dependency injection for repositories, logging, and Azure clients
  - `bootstrapper.py`: App startup, Azure client wiring, and logging setup
  - `config.py`: Environment variable management

---

## ⚙️ Azure Integration Highlights

- **Authentication:** Uses `DefaultAzureCredential` for secure, managed identity access to Azure resources.
- **Data Storage:** Agent and thread metadata are persisted in Cosmos DB containers.
- **Agent Operations:** All agent and thread operations are performed via the Azure AI SDK, ensuring cloud-native consistency.

---

## 🚦 API Endpoints

### `/api/agent`

- `GET /all`  
  List all agents stored in Cosmos DB.

- *(Planned)* `DELETE /reset/factory`  
  Reset all agents and threads (commented in code, for admin use).

### `/api/thread`

- `GET /`  
  Retrieve all messages for a thread (`thread_id`, `agent_id` as query params).

- `GET /all`  
  List all thread IDs for the authenticated user.

- `POST /`  
  Create a new thread for the authenticated user. Returns the new thread ID.

- `POST /message`  
  Add a new message to a thread and trigger agent processing. Returns recent messages.

- `DELETE /all`  
  Delete all threads for the authenticated user (and in Azure).

---

## 🧩 Dependency Injection & Security

- **User Authentication:**  
  - Uses `X-MS-CLIENT-PRINCIPAL-NAME` header for user identity (or a dev override).
  - All thread operations are scoped to the authenticated user.

- **Dependency Injection:**  
  - Repositories, Azure clients, and loggers are injected via FastAPI’s `Depends`.

---

## 🗄️ Data Models

- **Agent:**  
  - `id: str`
  - `name: str`

- **Thread:**  
  - `id: str`
  - `username: str`

- **Message:**  
  - Standard conversational message structure, with support for annotations.

---

## 🔒 Example: Secure Thread Creation

```python
@router.post("/")
async def new_thread(
    user_principal_name: Annotated[str, Depends(get_easy_auth_token)],
    project_client: Annotated[AIProjectClient, Depends(get_project_client)],
    thread_repository: Annotated[ThreadRepository, Depends(get_thread_repository)],
    logger: Annotated[Logger, Depends(get_logger)]
) -> str:
    # Creates a new thread in Azure AI Foundry and persists metadata in Cosmos DB
```

---

## 📦 Configuration

- All secrets and endpoints are managed via environment variables (`.env` file), loaded by `config.py`.
- Example variables:
  - `COSMOS_ENDPOINT`
  - `COSMOS_DATABASE`
  - `COSMOS_THREAD_CONTAINER`
  - `COSMOS_AGENT_CONTAINER`
  - `PROJECT_ENDPOINT`
  - `IS_DEVELOPMENT`
  - `USER_PRINCIPAL_NAME`

---

## 📊 Monitoring & Logging

- Azure Monitor is auto-configured if available.
- Logging level is set based on environment (`DEBUG` for development, `INFO` for production).
- All exceptions are globally handled and logged.

---

## 📝 Example Workflow

```plaintext
User (with Azure AD identity) → REST API → Azure AI SDK → Azure AI Foundry
                                 ↓
                           Cosmos DB (metadata)
                                 ↓
                        Azure Monitor (logs/traces)
```

---

## 🎯 Best Practices Followed

- **Cloud-native authentication and authorization**
- **Separation of concerns (API, data, Azure SDK)**
- **Observability with OpenTelemetry**
- **Environment-based configuration**
- **Secure, user-scoped data access**

---

## 🚀 Quickstart

1. Set up your `.env` file with Azure credentials and endpoints.
2. Install dependencies:  
   `pip install -r requirements.txt`
3. Run the API:  
   `uvicorn agentapi.main:app --reload`
4. Explore the docs at:  
   `http://localhost:8000/docs`

---

## 📚 Further Reading

- [Azure AI Foundry Documentation](https://learn.microsoft.com/en-us/azure/ai-services/foundry/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Azure Cosmos DB Python SDK](https://learn.microsoft.com/en-us/azure/cosmos-db/sql/sql-api-sdk-python)

---