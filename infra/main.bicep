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
module service 'br/public:avm/res/api-management/service:0.9.1' = {
  scope: rg
  params: {
    // Required parameters
    name: 'api-${resourceSuffix}'
    publisherEmail: publisherEmail
    publisherName: publisherName
    // Non-required parameters
    enableDeveloperPortal: true
    sku: apimSku
  }
}
