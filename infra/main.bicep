targetScope = 'subscription'

@description('The location where all resources will be created')
@allowed([
  'eastus2'
  'eastus'
  'westus'
  'westus3'
])
param location string

@description('The name of the resource group')
param resourceGroupName string

@description('Suffix for the resource group')
param suffix string

@description('Publisher Email admin for APIM')
param publisherEmail string

@description('Publisher Name for APIM')
param publisherName string

@description('The chat completion model to deploy, be sure its supported in the specific region')
@allowed([
  'gpt-4o-mini'
  'gpt-4.1-mini'
  'model-router'
])
param chatCompletionModel string

@description('The embedding model to deploy, be sure its supported in the specific region')
@allowed([
  'text-embedding-ada-002'
  'text-embedding-3-small'
  'text-embedding-3-large'
])
param embeddingModel string

@description('The SKU of APIM')
@allowed([
  'Developer'
  'BasicV2'
  'StandardV2'
  'Premium'
])
param apimSku string

//param userObjectId string

@description('The VNET address prefix')
param vnetAddressPrefix string

@description('The subnet address prefix for the private endpoints')
param addressPrefixSubnetPrivateEndpoint string

@description('The subnet address prefix for the agents')
param addressPrefixSubnetAgents string

@description('The prefix address of the jumpbox')
param addressPrefixSubnetJumpbox string

@description('The admin username of the jumpbox')
@secure()
param adminUsername string

@description('The admin password of the jumpbox')
@secure()
param adminPassword string

@description('The description of the project')
param projectDescription string

@description('The display name of the project')
param projectDisplayName string

@description('The name of the project')
param projectName string

@description('Switch if we deploy an instance of APIM')
param deployApim bool

/* Create the resource group */
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

/* Create all private DNS Zone needed */
module privatedns 'dns/private.dns.bicep' = {
  scope: rg
  params: {
    virtualNetworkResourceId: vnet.outputs.resourceId
    jumpboxIpv4Address: jumpbox.outputs.privateIPAdress
    jumpboxName: jumpbox.outputs.resourceName
  }
}

/* Suffix from the resource group if none specific */
var resourceSuffix = empty(suffix) ? uniqueString(rg.id) : suffix

/* Create the VNET that will host all the resource */
module vnet 'network/vnet.bicep' = {
  scope: rg
  params: {
    addressPrefixSubnetAgents: addressPrefixSubnetAgents
    addressPrefixSubnetJumpbox: addressPrefixSubnetJumpbox
    addressPrefixSubnetPrivateEndpoint: addressPrefixSubnetPrivateEndpoint
    vnetAddressPrefix: vnetAddressPrefix
  }
}

/* Jumpbox since everything is private to test the setup */
module jumpbox 'compute/jumpbox.bicep' = {
  scope: rg
  params: {
    location: location
    adminPassword: adminPassword
    adminUsername: adminUsername
    subnetResourceId: vnet.outputs.subnetResourceIds[2]
  }
}

/* API Management instace */
module apim 'br/public:avm/res/api-management/service:0.9.1' = if (deployApim) {
  scope: rg
  params: {
    // Required parameters    
    name: 'apimgnt-${resourceSuffix}'
    publisherEmail: publisherEmail
    publisherName: publisherName
    managedIdentities: {
      systemAssigned: true
    }
    // Non-required parameters
    enableDeveloperPortal: true
    sku: apimSku
  }
}

/* Deploy Azure AI Foundry */
module foundry 'ai/foundry.bicep' = {
  scope: rg
  params: {
    location: location
    chatCompletionModel: chatCompletionModel
    embeddingModel: embeddingModel
    suffix: resourceSuffix
    agentSubnetId: vnet.outputs.subnetResourceIds[1]
    aiServicesPrivateDnsZoneResourceId: privatedns.outputs.aiServicesPrivateDnsZoneResourceId
    cognitiveServicesPrivateDnsZoneResourceId: privatedns.outputs.cognitiveServicesPrivateDnsZoneResourceId
    openAiPrivateDnsZoneResourceId: privatedns.outputs.openAiPrivateDnsZoneResourceId
    privateEndpointSubnetResourceId: vnet.outputs.subnetResourceIds[0]
  }
}

/* OpenAI needed for indexation using the AI Search built-in capabilities */
/* Today seems we cannot use the OpenAI exposed in AI Services  */

module openai 'ai/openai.bicep' = {
  scope: rg
  params: {
    location: location
    suffix: resourceSuffix
  }
}

/* AI Search BYOD */
module search 'br/public:avm/res/search/search-service:0.7.2' = {
  scope: rg
  name: 'search'
  params: {
    disableLocalAuth: false
    authOptions: {
      aadOrApiKey: { aadAuthFailureMode: 'http401WithBearerChallenge' }
    }
    publicNetworkAccess: 'Disabled'
    networkRuleSet: {
      bypass: 'None'
      ipRules: []
    }
    name: 'search${replace(resourceSuffix,'-','')}'
    location: location
    managedIdentities: {
      systemAssigned: true
    }
    partitionCount: 1
    replicaCount: 1
    sku: 'standard'
    privateEndpoints: [
      {
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privatedns.outputs.aiSearchPrivateDnsZoneResourceId
            }
          ]
        }
      }
    ]
  }
}

/* Log analytics for Application Insights */
module workspace 'br/public:avm/res/operational-insights/workspace:0.11.2' = {
  scope: rg
  name: 'workspace'
  params: {
    name: 'log-${resourceSuffix}'
    dailyQuotaGb: 2
    dataRetention: 30
    location: location
  }
}

module insights 'br/public:avm/res/insights/component:0.6.0' = {
  scope: rg
  name: 'insights'
  params: {
    name: 'api-${resourceSuffix}'
    workspaceResourceId: workspace.outputs.resourceId
    location: location
  }
}

/* CosmosDB needed to associate Thread to logged user */

module cosmosdb 'br/public:avm/res/document-db/database-account:0.12.0' = {
  scope: rg
  params: {
    name: 'cos${replace(resourceSuffix,'-','')}'
    location: location
    enableMultipleWriteLocations: false
    automaticFailover: false
    disableLocalAuth: true
    networkRestrictions: {
      publicNetworkAccess: 'Disabled'
      networkAclBypass: 'AzureServices'
    }
    defaultConsistencyLevel: 'Session'
    privateEndpoints: [
      {
        service: 'Sql'
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privatedns.outputs.cosmosDBPrivateDnsZoneResourceId
            }
          ]
        }
      }
    ]
    locations: [
      {
        failoverPriority: 0
        isZoneRedundant: false
        locationName: location
      }
    ]
    sqlDatabases: [
      {
        name: 'chat'
        containers: [
          {
            name: 'thread'
            indexingPolicy: {
              automatic: true
            }
            paths: [
              '/username'
            ]
            kind: 'MultiHash'
          }
          {
            name: 'agent'
            indexingPolicy: {
              automatic: true
            }
            paths: [
              '/businessunit'
            ]
            kind: 'MultiHash'
          }
        ]
        throughput: 1000
        autoscaleSettingsMaxThroughput: 1000
      }
    ]
  }
}

/* Storage needed for the upload of the dataset and for AI Foundry */
module storage 'br/public:avm/res/storage/storage-account:0.19.0' = {
  scope: rg
  params: {
    name: 'str${replace(resourceSuffix,'-','')}'
    location: location
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: []
    }
    blobServices: {
      containers: [
        {
          name: 'upload'
        }
      ]
    }
    allowSharedKeyAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

/* Create an AI Foundry Project */
module project 'ai/project.bicep' = {
  scope: rg
  params: {
    location: location
    aiSearchName: search.outputs.name
    azureStorageName: storage.outputs.name
    cognitiveAccountName: foundry.outputs.resourceName
    cosmosDBName: cosmosdb.outputs.name
    projectDescription: projectDescription
    projectDisplayName: projectDisplayName
    projectName: projectName
  }
}

module formatProjectWorkspaceId 'ai/format-project-workspace-id.bicep' = {
  scope: rg
  params: {
    projectWorkspaceId: project.outputs.projectWorkspaceId
  }
}

module rbacproject 'rbac/project.bicep' = {
  scope: rg
  params: {
    cosmosDBResourceId: cosmosdb.outputs.resourceId
    projectPrincipalId: project.outputs.projectSystemManagedIdentityID
    storageResourceId: storage.outputs.resourceId
    aiSearchResourceId: search.outputs.resourceId
  }
}

module addProjectCapabilityHost 'ai/add-project-capability-host.bicep' = {
  scope: rg
  params: {
    accountName: foundry.outputs.resourceName
    aiSearchConnection: project.outputs.aiSearchConnection
    azureStorageConnection: project.outputs.azureStorageConnection
    cosmosDBConnection: project.outputs.cosmosDBConnection
    projectCapHost: 'caphostproj'
    projectName: project.outputs.projectName
  }
  dependsOn: [
    rbacproject
  ]
}

// Those RBAC needs to assigned after the creation of the caphost
// module caphostrbac 'rbac/caphost.bicep' = {
//   scope: rg
//   params: {
//     aiProjectPrincipalId: project.outputs.projectSystemManagedIdentityID
//     cosmosAccountName: cosmosdb.outputs.name
//     projectWorkspaceId: formatProjectWorkspaceId.outputs.projectWorkspaceIdGuid
//     storageName: storage.outputs.name
//   }
// }

/* APIM need with managed identity access to Foundry */
// module rbac 'rbac/foundry.bicep' = {
//   scope: rg
//   params: {
//     //foundryResourceId: foundry.outputs.resourceId
//     //apimSystemAssignedMIPrincipalId: apim.outputs.systemAssignedMIPrincipalId
//     openAIResourceId: openai.outputs.resourceId
//     aiSearchSystemAssignedMIPrincipalId: search.outputs.systemAssignedMIPrincipalId
//     storageResourceId: storage.outputs.resourceId
//     aiFoundrySystemAssignedMIPrincipalId: foundry.outputs.systemAssignedMIPrincipalId
//     aiSearchResourceId: search.outputs.resourceId
//     projectPrincipalSystemAssignedMIPrincipalId: project.outputs.projectSystemManagedIdentityID
//   }
// }

// module rbacUser 'rbac/user.rbac.bicep' = {
//   scope: rg
//   params: {
//     cosmosDbResourceName: cosmosdb.outputs.name
//     openAIResourceId: foundry.outputs.resourceId
//     searchResourceId: search.outputs.resourceId
//     storageResourceId: storage.outputs.resourceId
//     userObjectId: userObjectId
//   }
// }

output apimResourceName string = deployApim ? apim.outputs.name : ''
output foundryEndpoint string = foundry.outputs.endpoint
output accountResourceName string = foundry.outputs.resourceName
output aiSearchResourceName string = search.outputs.name
output azureStorageResourceName string = storage.outputs.name
output cosmosDbResourceName string = cosmosdb.outputs.name
output resourceGroupName string = resourceGroupName
output projectName string = projectName
