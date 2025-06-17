module aiServicesPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.services.ai.azure.com'
    // Non-required parameters
    location: 'global'
  }
}

module openAiPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.openai.azure.com'
    // Non-required parameters
    location: 'global'
  }
}

module cognitiveServicesPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.cognitiveservices.azure.com'
    // Non-required parameters
    location: 'global'
  }
}

module storagePrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    // Non-required parameters
    location: 'global'
  }
}

module cosmosDBPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.documents.azure.com'
    // Non-required parameters
    location: 'global'
  }
}
