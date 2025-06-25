param projectPrincipalId string
param storageResourceId string
param cosmosDBResourceId string
param aiSearchResourceId string

@description('Built-in Role: [Blob Storage Contributor]')
resource storageBlobDataContributor 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  scope: resourceGroup()
}

@description('Built-in Role: [CosmosDB Operator Role]')
resource cosmos_db_operator_role 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '230815da-be43-4aae-9cb4-875f7bd000aa'
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

module project_cosmos_db_role_operator 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'project_cosmos_db_role_operator'
  params: {
    principalId: projectPrincipalId
    resourceId: cosmosDBResourceId
    roleDefinitionId: cosmos_db_operator_role.id
  }
}

module storageBlobDataContributorRoleAssignmentProject 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'storageBlobDataContributorRoleAssignmentProject'
  params: {
    principalId: projectPrincipalId
    resourceId: storageResourceId
    roleDefinitionId: storageBlobDataContributor.id
  }
}

module project_search_index_data_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'project_search_index_data_contributor'
  params: {
    principalId: projectPrincipalId
    resourceId: aiSearchResourceId
    roleDefinitionId: search_index_data_contributor.id
  }
}

module project_search_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'project_search_contributor'
  params: {
    principalId: projectPrincipalId
    resourceId: aiSearchResourceId
    roleDefinitionId: search_data_contributor.id
  }
}
