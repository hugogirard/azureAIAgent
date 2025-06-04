param apimName string
param foundryEndpoint string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

resource service_genapimhg_name_AIFoundryBackend 'Microsoft.ApiManagement/service/backends@2024-05-01' = {
  parent: apim
  name: 'AIFoundryBackend'
  properties: {
    type: 'Single'
    url: '${foundryEndpoint}openai' // OpenAI is needed here
    protocol: 'http'
    credentials: {
      query: {}
      header: {}
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}
