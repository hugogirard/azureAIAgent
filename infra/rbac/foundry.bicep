param systemAssignedMIPrincipalId string
param foundryResourceId string

@description('Built-in Role: [Cognitive Services User]')
resource cognitive_services_user 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
  scope: subscription()
}

module apim_cognitive_services_user 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'cognitive_services_user'
  params: {
    principalId: systemAssignedMIPrincipalId
    resourceId: foundryResourceId
    roleDefinitionId: cognitive_services_user.id
  }
}
