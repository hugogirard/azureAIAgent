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
    name: 'api-${resourceSuffix}'
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

/* AI Search BYOD */
module search 'br/public:avm/res/search/search-service:0.7.2' = {
  scope: rg
  params: {
    disableLocalAuth: true
    name: 'search-${suffix}'
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
    name: 'cosmosdb-${suffix}'
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

/* APIM need with managed identity access to Foundry */
// module rbac 'rbac/foundry.bicep' = {
//   scope: rg
//   params: {
//     foundryResourceId: foundry.outputs.resourceId
//     systemAssignedMIPrincipalId: apim.outputs.systemAssignedMIPrincipalId
//   }
// }

@description('The name of APIM resource')
output apimResourceName string = apim.outputs.name

@description('The endpoint of Azure AI Foundry')
output foundryEndpoint string = foundry.outputs.endpoint
