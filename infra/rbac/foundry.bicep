param apimSystemAssignedMIPrincipalId string
param aiSearchSystemAssignedMIPrincipalId string
param openAIResourceId string
param foundryResourceId string

@description('Built-in Role: [Cognitive Services User]')
resource cognitive_services_user 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
  scope: subscription()
}

module apim_cognitive_services_user 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'cognitive_services_user'
  params: {
    principalId: apimSystemAssignedMIPrincipalId
    resourceId: foundryResourceId
    roleDefinitionId: cognitive_services_user.id
  }
}

module aisearch_cognitive_services_user 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'aisearch_cognitive_services_user'
  params: {
    principalId: aiSearchSystemAssignedMIPrincipalId
    resourceId: openAIResourceId
    roleDefinitionId: cognitive_services_user.id
  }
}
