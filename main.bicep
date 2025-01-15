@allowed([
  'uksouth'
  'ukwest'
])
param location string
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string
param businessunit string
//param dnsPrefix string
//param linuxAdminUsername string
//param sshRSAPublicKey string

var prefix = (environmentType == 'dev') ? 'AzD' : (environmentType == 'test') ? 'AzT' : 'AzP'
var ab = '-'
var ab2 = '_'
var reg = (location == 'uksouth') ? 'UKS' : 'UKW'
var pre  = '${prefix}${ab}${reg}${ab}'
var pre2 = '${prefix}${ab2}${reg}${ab2}'
var bu = businessunit
var logicAppName = 'Logic-App'
var logicAppName2 = 'Logic_App'
var logicAppN = '${pre}${bu}-${logicAppName}'
var logicAppN2 = '${pre2}${bu}_${logicAppName2}'
//var logicAppN3 = '${pre2}${bu}_${logicAppName2}'


var tags = resourceGroup().tags

module storageaccount 'modules/storageaccount.bicep' = {
  name: 'storageaccount'
  params: {
    environmentType:environmentType
    location: location
    tags:tags 
  }
}
//output storageAccountName string = storageaccount.outputs.ostorageAccountName


/*module appService 'modules/appservice.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    tags:tags
  }
}*/

module vnet 'Modules/networking.bicep' = {
  name: 'vnet'
params:{
  logicAppN0:logicAppN2
  location:location
  tags:tags
  }
}

/*module natGateway 'modules/nat.bicep' = {
  name: 'natGateway'
  params: {
    virtualNetwork: vnet.outputs.ovirtualNetwork
    subnet1Name:vnet.outputs.osubnet1Name
    subnet2Name:vnet.outputs.osubnet2Name
    logicAppN: logicAppN3
    location: location
    tags:tags
  }
}*/

module logicapp 'modules/logicappst.bicep' = {
  name: 'logicapp'
  params: {
    logicAppN0:logicAppN
    location: location
    environmentType: environmentType
    virtualNetworkSubnetId: vnet.outputs.ovirtualNetworkSubnetId
    storageAccountName:storageaccount.outputs.ostorageAccountName
    tags:tags
  }
}



/*module aks 'Modules/aks.bicep' = {
  name:'aks'
params:{
  dnsPrefix:dnsPrefix
  linuxAdminUsername:linuxAdminUsername
  sshRSAPublicKey:sshRSAPublicKey
  tags:tags
}
}*/

//output appServiceAppName string = appService.outputs.appServiceAppName
