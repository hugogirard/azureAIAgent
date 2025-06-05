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

/* APIM need with managed identity access to Foundry */
module rbac 'rbac/foundry.bicep' = {
  scope: rg
  params: {
    foundryResourceId: foundry.outputs.resourceId
    systemAssignedMIPrincipalId: apim.outputs.systemAssignedMIPrincipalId
  }
}
