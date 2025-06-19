param projectName string
param accountName string
param projectCapHost string
param cosmosDBName string
param azureStorageName string
param aiSearchName string

var threadConnections = ['${cosmosDBName}']
var storageConnections = ['${azureStorageName}']
var vectorStoreConnections = ['${aiSearchName}']

resource account 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: accountName
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' existing = {
  name: projectName
  parent: account
}

resource projectCapabilityHost 'Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview' = {
  name: projectCapHost
  parent: project
  properties: {
    capabilityHostKind: 'Agents'
    vectorStoreConnections: vectorStoreConnections
    storageConnections: storageConnections
    threadStorageConnections: threadConnections
  }
}

output projectCapHost string = projectCapabilityHost.name
