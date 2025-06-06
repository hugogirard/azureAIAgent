param userObjectId string
param searchResourceId string
param openAIResourceId string
param storageResourceId string
param cosmosDbResourceName string

@description('Built-in Role: [Search Index Data Contributor]')
resource searchIndexDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
  scope: subscription()
}

@description('Built-in Role: [Cognitive Services OpenAI Contributor]')
resource cognitive_service_openai_contributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a001fd3d-188f-4b5d-821b-7da978bf7442'
  scope: subscription()
}

@description('Built-in Role: [Storage Blob Data Contributor]')
resource storageBlobDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  scope: subscription()
}

module openai_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'openai_contributor'
  params: {
    principalId: userObjectId
    resourceId: openAIResourceId
    roleDefinitionId: cognitive_service_openai_contributor.id
  }
}

module search_index_data_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'search_index_data_contributor'
  params: {
    principalId: userObjectId
    resourceId: searchResourceId
    roleDefinitionId: searchIndexDataContributor.id
  }
}

module storage_blob_data_contributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: 'storage_blob_data_contributor'
  params: {
    principalId: userObjectId
    resourceId: storageResourceId
    roleDefinitionId: storageBlobDataContributor.id
  }
}

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
  name: cosmosDbResourceName
}

@description('Built-in Role: [Cosmos DB Built-in Data Contributor]')
resource cosmosDbDataContributorRole 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' existing = {
  name: '00000000-0000-0000-0000-000000000002'
  parent: cosmosdb
}

resource assignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  name: guid(cosmosDbDataContributorRole.id, userObjectId, cosmosdb.id)
  parent: cosmosdb
  properties: {
    principalId: userObjectId
    roleDefinitionId: cosmosDbDataContributorRole.id
    scope: cosmosdb.id
  }
}
