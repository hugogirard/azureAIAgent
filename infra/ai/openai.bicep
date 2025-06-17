param location string
param suffix string

var openAIResourceName = 'openai${replace(suffix,'-','')}'

resource openai 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: openAIResourceName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {}
    customSubDomainName: openAIResourceName
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: []
    }
    allowProjectManagement: false
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: false
    disableLocalAuth: true
    dynamicThrottlingEnabled: false
  }
}

resource deployment_text_embedding_3_small 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  parent: openai
  name: 'text-embedding-3-small'
  sku: {
    name: 'GlobalStandard'
    capacity: 150
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-small'
      version: '1'
    }
    versionUpgradeOption: 'NoAutoUpgrade'
    currentCapacity: 150
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

output resourceId string = openai.id
