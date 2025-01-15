param location string
param tags object
param logicAppN0 string

var pe = 'PE'
var endpoint = '${logicAppN0}${pe}'
var logicAppName = '_Vnet'
var logicAppN2 = '${logicAppN0}${logicAppName}'

var virtualNetworkName = logicAppN2
var natGatewayName = '${logicAppN2}_Nat'
var subnet1Name = '${logicAppN0}_Subnet'
var subnet2Name = '${endpoint}_Subnet'

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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: virtualNetworkName
  location: location
  tags:tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    }
  }

  resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {    
    name: subnet1Name
    parent: virtualNetwork
    properties: {  
      addressPrefix: '10.0.0.0/28'
      natGateway: {
        id: natGatewayResource.id
      }   
      // delegations: delegations    
      delegations:[    
        {    
          name: 'delegation'    
          properties:{    
            serviceName: 'Microsoft.Web/serverfarms'    
          }    
        }    
      ]
      privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'    
    }    
  }

  resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {    
    name: subnet2Name
    parent: virtualNetwork
    properties: {  
      addressPrefix: '10.0.0.16/28'
      natGateway: {
        id: natGatewayResource.id
      }   
      // delegations: delegations    
      delegations:[    
        {    
          name: 'delegation'    
          properties:{    
            serviceName: 'Microsoft.Web/serverfarms'    
          }    
        }    
      ]   
      privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled' 
    }    
    
  }
  
  var vnetSubnetId = resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnet1Name)

  output ovirtualNetworkSubnetId string = vnetSubnetId
  output ovirtualNetwork string = virtualNetworkName
  output osubnet1Name string = subnet1Name
  output osubnet2Name string = subnet2Name
