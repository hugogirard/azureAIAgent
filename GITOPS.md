## GitOps Workflow for Azure AI Foundry Agents

This project uses GitOps principles to manage the lifecycle of agents in Azure AI Foundry. All agent configurations and logic are stored in this repository, and automated scripts ensure the deployed state in Azure matches the source of truth in Git.

### Key GitOps Principles Applied

- **Declarative Configuration:**  
  Each agent and multi-agent is defined as a Python class in the `agents/` and `multi_agent/` directories. These classes encapsulate all configuration, tools, and instructions for each agent.

- **Version Control as Source of Truth:**  
  All agent definitions and configurations are versioned in Git. Changes are made via pull requests, ensuring traceability and auditability.

- **Automated Reconciliation:**  
  The main script (`main.py`) scans the repository for agent definitions, compares them with the current state in Azure AI Foundry, and creates or updates agents as needed to match the desired state.

- **Continuous Delivery:**  
  Running the automation script (manually or in CI/CD) applies any changes from the repository to Azure AI Foundry, enabling repeatable and automated deployments.

- **Separation of Concerns:**  
  Agent logic and configuration are separated from deployment logic. The repository acts as the single source of truth, while the Python automation acts as the reconciler.

### Workflow Overview

1. **Agent Discovery:**  
   The utility functions scan the `agents/` and `multi_agent/` directories for agent classes.

2. **Desired State Construction:**  
   Each agent class provides a method to return its configuration.

3. **Current State Fetch:**  
   The script queries Azure AI Foundry for existing agents using the Azure SDK.

4. **Reconciliation:**  
   The script compares the desired state (from Git) with the current state (in Azure) and creates or updates agents as needed.

5. **Persistence:**  
   Agent metadata is stored in Cosmos DB for tracking and management.

### Benefits

- **Traceable and auditable agent changes**
- **Automated, repeatable deployments**
- **Single source of truth for all agent configurations**

---