param location string
param environmentType string
param storageAccountName string
param tags object
param virtualNetworkSubnetId string
param logicAppN0 string

var logicAppName = 'Logic-App-Te'
var logicAppN = '${logicAppN0}-${logicAppName}'
var appServicePlanName = '${logicAppN}-Service-Plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'WS1'

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags:tags
  sku: {
    name: appServicePlanSkuName
  }
}

resource logicAppTest 'Microsoft.Web/sites@2021-02-01' = {
  name: logicAppN
  location: location
  kind: 'functionapp,workflowapp'
  identity: {
      type: 'SystemAssigned'
  }
  tags:tags
  properties: {
      httpsOnly: true
      siteConfig: {
        appSettings: [
          { name: 'APP_KIND', value: 'workflowApp' }
            //Storage settings
            {
              name: 'AzureWebJobsStorage'
              // Here we can securely get the access key
              value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${storageaccount.listKeys().keys[0].value}'
            }
            {name: 'FUNCTIONS_EXTENSION_VERSION'
             value: '~4' }
             {name:'AzureFunctionsJobHost__extensionBundle__id'
            value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
          }
          {name:'AzureFunctionsJobHost__extensionBundle__version'
        value:'[1.*, 2.0.0)'}
        {name:'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'}
          {name:'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value:'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${storageaccount.listKeys().keys[0].value}'}
        {name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value:'~18'}
        ]
          use32BitWorkerProcess: true
      }
      virtualNetworkSubnetId: virtualNetworkSubnetId
      serverFarmId: appServicePlan.id
      clientAffinityEnabled: false
  }
}

output ologicAppN string = logicAppN
