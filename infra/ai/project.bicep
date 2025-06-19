param aiSearchName string
param cosmosDBName string
param azureStorageName string
param cognitiveAccountName string
param projectName string
param location string
param projectDescription string
param projectDisplayName string

resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: aiSearchName
}

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2024-12-01-preview' existing = {
  name: cosmosDBName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: azureStorageName
}

resource account 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: cognitiveAccountName
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  parent: account
  name: projectName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: projectDescription
    displayName: projectDisplayName
  }

  resource project_connection_cosmosdb_account 'connections@2025-04-01-preview' = {
    name: cosmosDBName
    properties: {
      category: 'CosmosDB'
      target: cosmosDBAccount.properties.documentEndpoint
      authType: 'AAD'
      metadata: {
        ApiType: 'Azure'
        ResourceId: cosmosDBAccount.id
        location: cosmosDBAccount.location
      }
    }
  }

  resource project_connection_azure_storage 'connections@2025-04-01-preview' = {
    name: azureStorageName
    properties: {
      category: 'AzureStorageAccount'
      target: storageAccount.properties.primaryEndpoints.blob
      authType: 'AAD'
      metadata: {
        ApiType: 'Azure'
        ResourceId: storageAccount.id
        location: storageAccount.location
      }
    }
  }

  resource project_connection_azureai_search 'connections@2025-04-01-preview' = {
    name: aiSearchName
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${aiSearchName}.search.windows.net'
      authType: 'AAD'
      metadata: {
        ApiType: 'Azure'
        ResourceId: searchService.id
        location: searchService.location
      }
    }
  }
}

output projectResourceName string = project.name
output projectSystemManagedIdentityID string = project.identity.principalId
