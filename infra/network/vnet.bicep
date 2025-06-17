param vnetAddressPrefix string
param addressPrefixSubnetPrivateEndpoint string
param addressPrefixSubnetAgents string
param addressPrefixSubnetJumpbox string

module nsgPE 'br/public:avm/res/network/network-security-group:0.5.1' = {
  params: {
    name: 'nsg-pe'
  }
}

module nsgAgent 'br/public:avm/res/network/network-security-group:0.5.1' = {
  params: {
    name: 'nsg-pe'
  }
}

module nsgJumpbox 'br/public:avm/res/network/network-security-group:0.5.1' = {
  params: {
    name: 'nsg-jumpbox'
  }
}

module vnet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  params: {
    name: 'vnet-agent'
    addressPrefixes: [
      vnetAddressPrefix
    ]
    subnets: [
      {
        name: 'pe-subnet'
        addressPrefix: addressPrefixSubnetPrivateEndpoint
        networkSecurityGroupResourceId: nsgPE.outputs.resourceId
      }
      {
        name: 'pe-agent'
        addressPrefix: addressPrefixSubnetAgents
        delegation: 'Microsoft.app/environments'
        networkSecurityGroupResourceId: nsgAgent.outputs.resourceId
      }
      {
        name: 'pe-jumpbox'
        addressPrefix: addressPrefixSubnetJumpbox
        networkSecurityGroupResourceId: nsgJumpbox.outputs.resourceId
      }
    ]
  }
}

output resourceId string = vnet.outputs.resourceId
output subnetResourceIds array = vnet.outputs.subnetResourceIds
