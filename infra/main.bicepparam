using 'main.bicep'

// param apimSku = 'Developer'

param location = 'eastus2'

// param publisherEmail = 'contoso@gmail.com'

// param publisherName = 'Contoso'

param resourceGroupName = 'rg-agent-demo'

param suffix = ''

param chatCompletionModel = 'gpt-4o-mini'

param embeddingModel = 'text-embedding-3-small'

// param userObjectId = '307779dd-2bab-46a1-826a-f073d039af49'

param vnetAddressPrefix = '172.16.0.0/16'

param addressPrefixSubnetAgents = '172.16.0.0/24'

param addressPrefixSubnetPrivateEndpoint = '172.16.101.0/24'

param addressPrefixSubnetJumpbox = '172.16.102.0/28'

param adminPassword = ''

param adminUsername = ''

param projectDescription: 'Contoso Project'

param projectDisplayName: 'contoso'

param projectName: 'contoso'
