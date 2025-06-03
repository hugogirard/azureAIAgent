using 'main.bicep'

param apimSku = 'Developer'

param location = 'eastus2'

param publisherEmail = 'contoso@gmail.com'

param publisherName = 'Contoso'

param resourceGroupName = 'rg-genai-demo'

param suffix = ''

param chatCompletionModels = [
  'gpt-4o-mini'
]

param embeddingModels = [
  'text-embedding-3-small'
]
