//param apimSystemAssignedMIPrincipalId string
param aiSearchSystemAssignedMIPrincipalId string
param aiFoundrySystemAssignedMIPrincipalId string
param projectPrincipalSystemAssignedMIPrincipalId string
param openAIResourceId string
//param foundryResourceId string
param storageResourceId string
param aiSearchResourceId string

@description('Built-in Role: [Cognitive Services User]')
resource cognitive_services_user 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
  scope: subscription()
}

@description('Built-in Role: [Blob Storage Contributor]')
resource storageBlobDataContributor 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  scope: resourceGroup()
}

@description('Built-in Role: [Storage Blob Data Reader]')
resource storage_blob_data_reader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  scope: subscription()
}

@description('Built-in Role: [Search Index Data Contributor]')
resource search_index_data_contributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
  scope: subscription()
}

@description('Built-in Role: [Search Service Contributor]')
resource search_data_contributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
  scope: subscription()
}

@description('Built-in Role: [CosmosDB Operator Role]')
resource cosmos_db_operator_role 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '230815da-be43-4aae-9cb4-875f7bd000aa'
  scope: subscription()
}

// module apim_cognitive_services_user 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
//   name: 'cognitive_services_user'
//   params: {
//     principalId: apimSystemAssignedMIPrincipalId
//     resourceId: foundryResourceId
//     roleDefinitionId: cognitive_services_user.id
//   }
// }

module aisearch_cognitive_services_user 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'aisearch_cognitive_services_user'
  params: {
    principalId: aiSearchSystemAssignedMIPrincipalId
    resourceId: openAIResourceId
    roleDefinitionId: cognitive_services_user.id
  }
}

module ai_search_blob_data_reader 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'ai_search_blob_data_reader'
  params: {
    principalId: aiSearchSystemAssignedMIPrincipalId
    resourceId: storageResourceId
    roleDefinitionId: storage_blob_data_reader.id
  }
}

// 	Search Index Data Contributor
module aisearch_search_index_data_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'aisearch_search_index_data_contributor'
  params: {
    principalId: aiFoundrySystemAssignedMIPrincipalId
    resourceId: aiSearchResourceId
    roleDefinitionId: search_index_data_contributor.id
  }
}

module storageBlobDataContributorRoleAssignmentProject 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'storageBlobDataContributorRoleAssignmentProject'
  params: {
    principalId: projectPrincipalSystemAssignedMIPrincipalId
    resourceId: storageResourceId
    roleDefinitionId: storageBlobDataContributor.id
  }
}

module project_cosmos_db_role_operator 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'project_cosmos_db_role_operator'
  params: {
    principalId: projectPrincipalSystemAssignedMIPrincipalId
    resourceId: storageResourceId
    roleDefinitionId: cosmos_db_operator_role.id
  }
}

module project_search_index_data_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'project_search_index_data_contributor'
  params: {
    principalId: projectPrincipalSystemAssignedMIPrincipalId
    resourceId: aiSearchResourceId
    roleDefinitionId: search_index_data_contributor.id
  }
}

module project_search_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'project_search_contributor'
  params: {
    principalId: projectPrincipalSystemAssignedMIPrincipalId
    resourceId: aiSearchResourceId
    roleDefinitionId: search_data_contributor.id
  }
}
