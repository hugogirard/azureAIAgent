param apimName string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

resource foundry 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'foundry'
  properties: {
    displayName: 'foundry'
    apiRevision: '1'
    description: 'Azure OpenAI APIs for completions and search'
    subscriptionRequired: true
    path: 'gen/openai'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'api-key'
      query: 'subscription-key'
    }
    isCurrent: true
    format: 'openapi-link'
    value: loadTextContent('./openapi.final.yaml')
  }
}

resource foundryPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: foundry
  name: 'policy'
  properties: {
    format: 'xml'
    value: loadTextContent('./policy.xml')
  }
}
