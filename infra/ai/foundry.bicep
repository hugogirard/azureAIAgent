param location string
param suffix string
param chatCompletionModels array
param embeddingModels array

var aiFoundryName = 'foundry-${suffix}'

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: aiFoundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    // required to work in AI Foundry
    allowProjectManagement: true
    // Defines developer API endpoint subdomain
    customSubDomainName: aiFoundryName
    disableLocalAuth: true
  }
}

/*
  Developer APIs are exposed via a project, which groups in- and outputs that relate to one use case, including files.
  Its advisable to create one project right away, so development teams can directly get started.
  Projects may be granted individual RBAC permissions and identities on top of what account provides.
*/
resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  name: 'contoso'
  parent: aiFoundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

/*
  Optionally deploy a model to use in playground, agents and other tools.
*/
resource chatModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [
  for model in chatCompletionModels: {
    parent: aiFoundry
    name: model
    sku: {
      capacity: 1
      name: 'GlobalStandard'
    }
    properties: {
      model: {
        name: model
        format: 'OpenAI'
      }
    }
  }
]

resource embeddingModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [
  for model in embeddingModels: {
    parent: aiFoundry
    name: model
    sku: {
      capacity: 1
      name: 'GlobalStandard'
    }
    properties: {
      model: {
        name: model
        format: 'OpenAI'
      }
    }
  }
]
