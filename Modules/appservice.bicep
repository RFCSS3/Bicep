param location string
param environmentType string
param tags object
var prefix = (environmentType == 'dev') ? 'AzD' : (environmentType == 'test') ? 'AzT' : 'AzP'
var ab = '-'
var reg = (location == 'uksouth') ? 'UKS' : 'UKW'

var pre  = '${prefix}${ab}${reg}${ab}'
var appServiceAppName = 'Web-Application'
var appservicenm = '${pre}${(appServiceAppName)}'
var appServicePlanName = '${appservicenm}-Service-Plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'B1'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags:tags
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appservicenm
  location: location
  tags:tags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
output appServiceAppName string = appservicenm
