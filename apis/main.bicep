@description('The name of your instance of APIM')
param apimName string

@description('The endpoint of Azure AI Foundry to reach your model')
param endpointFoundry string

module backend 'backend/backend.bicep' = {
  name: 'backend'
  params: {
    apimName: apimName
    foundryEndpoint: endpointFoundry
  }
}
