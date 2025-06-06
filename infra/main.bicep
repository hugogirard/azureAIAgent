targetScope = 'subscription'

@description('The location where all resources will be created')
@allowed([
  'eastus2'
  'canadacentral'
])
param location string

@description('The name of the resource group')
param resourceGroupName string

@description('Suffix for the resource group')
param suffix string

@description('Publisher Email admin for APIM')
param publisherEmail string

@description('Publisher Name for APIM')
param publisherName string

@description('The chat completion model to deploy, be sure its supported in the specific region')
@allowed([
  'gpt-4o-mini'
  'gpt-4.1-mini'
  'model-router'
])
param chatCompletionModel string

@description('The embedding model to deploy, be sure its supported in the specific region')
@allowed([
  'text-embedding-ada-002'
  'text-embedding-3-small'
  'text-embedding-3-large'
])
param embeddingModel string

@description('The SKU of APIM')
@allowed([
  'Developer'
  'BasicV2'
  'StandardV2'
  'Premium'
])
param apimSku string

param userObjectId string

/* Create the resource group */
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

/* Suffix from the resource group if none specific */
var resourceSuffix = empty(suffix) ? uniqueString(rg.id) : suffix

/* API Management instace */
module apim 'br/public:avm/res/api-management/service:0.9.1' = {
  scope: rg
  params: {
    // Required parameters    
    name: 'apim-${resourceSuffix}'
    publisherEmail: publisherEmail
    publisherName: publisherName
    managedIdentities: {
      systemAssigned: true
    }
    // Non-required parameters
    enableDeveloperPortal: true
    sku: apimSku
  }
}

/* Deploy Azure AI Foundry */
module foundry 'ai/foundry.bicep' = {
  scope: rg
  params: {
    location: location
    chatCompletionModel: chatCompletionModel
    embeddingModel: embeddingModel
    suffix: resourceSuffix
  }
}

/* OpenAI needed for indexation only for the demo */

module openai 'ai/openai.bicep' = {
  scope: rg
  params: {
    location: location
    suffix: resourceSuffix
  }
}

/* AI Search BYOD */
module search 'br/public:avm/res/search/search-service:0.7.2' = {
  scope: rg
  name: 'search'
  params: {
    disableLocalAuth: true
    name: 'search${replace(resourceSuffix,'-','')}'
    location: location
    managedIdentities: {
      systemAssigned: true
    }
    partitionCount: 1
    replicaCount: 1
    sku: 'standard'
  }
}

/* CosmosDB needed to associate Thread to logged user */

module cosmosdb 'br/public:avm/res/document-db/database-account:0.12.0' = {
  scope: rg
  params: {
    name: 'cos${replace(resourceSuffix,'-','')}'
    location: location
    enableMultipleWriteLocations: false
    automaticFailover: false
    disableLocalAuth: true
    networkRestrictions: {
      publicNetworkAccess: 'Enabled'
    }
    locations: [
      {
        failoverPriority: 0
        isZoneRedundant: false
        locationName: location
      }
    ]
    sqlDatabases: [
      {
        name: 'chat'
        containers: [
          {
            name: 'thread'
            indexingPolicy: {
              automatic: true
            }
            paths: [
              '/username'
            ]
            kind: 'MultiHash'
          }
        ]
        throughput: 1000
        autoscaleSettingsMaxThroughput: 1000
      }
    ]
  }
}

/* Storage needed for the upload of the dataset */
module storage 'br/public:avm/res/storage/storage-account:0.19.0' = {
  scope: rg
  params: {
    name: 'str${replace(resourceSuffix,'-','')}'
    location: location
    allowBlobPublicAccess: true
    networkAcls: {
      defaultAction: 'Allow'
    }
    blobServices: {
      containers: [
        {
          name: 'upload'
        }
      ]
    }
    allowSharedKeyAccess: false
    publicNetworkAccess: 'Enabled'
  }
}

/* APIM need with managed identity access to Foundry */
module rbac 'rbac/foundry.bicep' = {
  scope: rg
  params: {
    foundryResourceId: foundry.outputs.resourceId
    apimSystemAssignedMIPrincipalId: apim.outputs.systemAssignedMIPrincipalId
    openAIResourceId: openai.outputs.resourceId
    aiSearchSystemAssignedMIPrincipalId: search.outputs.systemAssignedMIPrincipalId
    storageResourceId: storage.outputs.resourceId
    aiFoundrySystemAssignedMIPrincipalId: foundry.outputs.systemAssignedMIPrincipalId
    aiSearchResourceId: search.outputs.systemAssignedMIPrincipalId
  }
}

module rbacUser 'rbac/user.rbac.bicep' = {
  scope: rg
  params: {
    cosmosDbResourceName: cosmosdb.outputs.name
    openAIResourceId: foundry.outputs.resourceId
    searchResourceId: search.outputs.resourceId
    storageResourceId: storage.outputs.resourceId
    userObjectId: userObjectId
  }
}

@description('The name of APIM resource')
output apimResourceName string = apim.outputs.name

@description('The endpoint of Azure AI Foundry')
output foundryEndpoint string = foundry.outputs.endpoint
