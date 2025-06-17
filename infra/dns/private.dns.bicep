param virtualNetworkResourceId string
param jumpboxIpv4Address string
param jumpboxName string

module aiServicesPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.services.ai.azure.com'
    // Non-required parameters
    location: 'global'
    a: [
      {
        name: jumpboxName
        ttl: 10
        aRecords: [
          {
            ipv4Address: jumpboxIpv4Address
          }
        ]
      }
    ]
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: virtualNetworkResourceId
      }
    ]
  }
}

module openAiPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.openai.azure.com'
    // Non-required parameters
    location: 'global'
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: virtualNetworkResourceId
      }
    ]
  }
}

module cognitiveServicesPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.cognitiveservices.azure.com'
    // Non-required parameters
    location: 'global'
    a: [
      {
        name: jumpboxName
        ttl: 10
        aRecords: [
          {
            ipv4Address: jumpboxIpv4Address
          }
        ]
      }
    ]
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: virtualNetworkResourceId
      }
    ]
  }
}

module storagePrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    // Non-required parameters
    location: 'global'
    a: [
      {
        name: jumpboxName
        ttl: 10
        aRecords: [
          {
            ipv4Address: jumpboxIpv4Address
          }
        ]
      }
    ]
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: virtualNetworkResourceId
      }
    ]
  }
}

module cosmosDBPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.1' = {
  params: {
    name: 'privatelink.documents.azure.com'
    // Non-required parameters
    location: 'global'
    a: [
      {
        name: jumpboxName
        ttl: 10
        aRecords: [
          {
            ipv4Address: jumpboxIpv4Address
          }
        ]
      }
    ]
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: virtualNetworkResourceId
      }
    ]
  }
}

output aiServicesPrivateDnsZoneResourceId string = aiServicesPrivateDnsZone.outputs.resourceId
output openAiPrivateDnsZoneResourceId string = openAiPrivateDnsZone.outputs.resourceId
output cognitiveServicesPrivateDnsZoneResourceId string = cognitiveServicesPrivateDnsZone.outputs.resourceId
output storagePrivateDnsZoneResourceId string = storagePrivateDnsZone.outputs.resourceId
output cosmosDBPrivateDnsZoneResourceId string = cosmosDBPrivateDnsZone.outputs.resourceId
