param location string
param suffix string
param chatCompletionModel string
param embeddingModel string
param agentSubnetId string
param privateEndpointSubnetResourceId string
param aiServicesPrivateDnsZoneResourceId string
param openAiPrivateDnsZoneResourceId string
param cognitiveServicesPrivateDnsZoneResourceId string

var aiFoundryName = 'aifoundry${suffix}'
//var networkInjection = 'true'

#disable-next-line BCP036
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
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    // required to work in AI Foundry
    allowProjectManagement: true
    // true is not supported today
    disableLocalAuth: false
    customSubDomainName: aiFoundryName
    networkInjections: [
      {
        scenario: 'agent'
        subnetArmId: agentSubnetId
        useMicrosoftManagedNetwork: false
      }
    ]
  }
}

resource aiAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${aiFoundry.name}-private-endpoint'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: privateEndpointSubnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: '${aiFoundry.name}-private-link-service-connection'
        properties: {
          privateLinkServiceId: aiFoundry.id
          groupIds: [
            'account' // Target AI Services account
          ]
        }
      }
    ]
  }
}

resource aiServicesDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: aiAccountPrivateEndpoint
  name: '${aiFoundry.name}-dns-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${aiFoundry.name}-dns-aiserv-config'
        properties: {
          privateDnsZoneId: aiServicesPrivateDnsZoneResourceId
        }
      }
      {
        name: '${aiFoundry.name}-dns-openai-config'
        properties: {
          privateDnsZoneId: openAiPrivateDnsZoneResourceId
        }
      }
      {
        name: '${aiFoundry.name}-dns-cogserv-config'
        properties: {
          privateDnsZoneId: cognitiveServicesPrivateDnsZoneResourceId
        }
      }
    ]
  }
}

/*
  Developer APIs are exposed via a project, which groups in- and outputs that relate to one use case, including files.
  Its advisable to create one project right away, so development teams can directly get started.
  Projects may be granted individual RBAC permissions and identities on top of what account provides.
*/
// resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
//   name: 'contoso'
//   parent: aiFoundry
//   location: location
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {}
// }

/*
  Optionally deploy a model to use in playground, agents and other tools.
*/
resource chatModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiFoundry
  name: chatCompletionModel
  sku: {
    capacity: 1
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      name: chatCompletionModel
      format: 'OpenAI'
    }
  }
}

resource embeddingModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiFoundry
  dependsOn: [
    chatModelDeployment
  ]
  name: embeddingModel
  sku: {
    capacity: 1
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      name: embeddingModel
      format: 'OpenAI'
    }
  }
}

output resourceId string = aiFoundry.id
output resourceName string = aiFoundry.name
output endpoint string = aiFoundry.properties.endpoint
output systemAssignedMIPrincipalId string = aiFoundry.identity.principalId
