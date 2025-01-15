param location string
param environmentType string
param tags object

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var prefix = (environmentType == 'dev') ? 'azd' : (environmentType == 'test') ? 'azt' : 'azp'
var reg = (location == 'uksouth') ? 'uks' : 'ukw'
var pre  = '${prefix}${reg}'
var storageAccountName  = '${toLower(pre)}${uniqueString(resourceGroup().id)}'

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags:tags
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}


output ostorageAccountName string = storageaccount.name
output olocation string = storageaccount.location
output oenvironmentType  string = environmentType
output opre string = pre
