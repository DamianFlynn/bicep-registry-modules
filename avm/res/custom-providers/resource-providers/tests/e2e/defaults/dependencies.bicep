@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

@description('Required. The name of the Function Application to create.')
param functionAppName string

@description('The Uri to the uploaded function zip file')
param zipFileBlobUri string

@description('Optional. Tags to apply to the resources.')
param tags object = {}

param eventHubName string
param eventHubAuthorizationRuleResourceId string
param storageAccountResourceId string
param workspaceResourceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${functionAppName}-appinsights'
  location: location
  kind: ''
  properties: {}
}

module custProviderFarm 'br/public:avm/res/web/serverfarm:0.1.1' = {
  name: '${functionAppName}-farm'
  params: {
    name: functionAppName
    location: location
    tags: tags
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
      size: 'Y1'
      family: 'Y'
      capacity: 0
    }
  }
}

module custProviderFuntionApp 'br/public:avm/res/web/site:0.3.5' = {
  name: '${functionAppName}-func'
  params: {
    name: functionAppName
    kind: 'functionapp'
    tags: tags
    serverFarmResourceId: custProviderFarm.outputs.resourceId
    appInsightResourceId: applicationInsights.id
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
      SCM_DO_BUILD_DURING_DEPLOYMENT: true
      WEBSITE_RUN_FROM_PACKAGE: zipFileBlobUri
    }
    siteConfig: {
      clientAffinityEnabled: false
      reserved: false
    }
    managedIdentities: {
      systemAssigned: true
    }
    diagnosticSettings: [
      {
        eventHubName: eventHubName
        eventHubAuthorizationRuleResourceId: eventHubAuthorizationRuleResourceId
        storageAccountResourceId: storageAccountResourceId
        workspaceResourceId: workspaceResourceId
      }
    ]
  }
}

output functionAppName string = custProviderFuntionApp.outputs.name
output functionAppId string = custProviderFuntionApp.outputs.resourceId
