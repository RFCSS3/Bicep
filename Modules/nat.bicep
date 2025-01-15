param location string
param tags object
param logicAppN string
param virtualNetwork string
param subnet1Name string
param subnet2Name string

var natGatewayName = '${logicAppN}_Nat'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: virtualNetwork
}

resource publicip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name:'Public_IP'
  location: location
  sku: {
    name: 'Standard'
  }
  tags:tags
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource natGatewayResource'Microsoft.Network/natGateways@2024-05-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  tags:tags
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicip.id
      }
    ]
  }
}

resource updatedsubnet01 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  parent: vnet
  name: subnet1Name  // this needs to be static values, as calculated at start of deployment. so you cannot put the name of subnet as vnet.properties.subnets[0].properties.name
  properties: {
    addressPrefix: vnet.properties.subnets[0].properties.addressPrefix
    natGateway: {
      id: natGatewayResource.id
    }
  }
}

resource updatedsubnet02 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  parent: vnet
  name: subnet2Name  // this needs to be static values, as calculated at start of deployment. so you cannot put the name of subnet as vnet.properties.subnets[0].properties.name
  properties: {
    addressPrefix: vnet.properties.subnets[0].properties.addressPrefix
    natGateway: {
      id: natGatewayResource.id
    }
  }
}
