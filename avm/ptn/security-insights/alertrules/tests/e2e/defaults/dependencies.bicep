@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

@description('Required. A name to apply on the workspace we create.')
param logAnalyticsName string

/* Log analytics workspace */

module workspace 'br/public:avm/res/operational-insights/workspace:0.2.0' = {
  name: '${uniqueString(deployment().name, location)}-test-oiwmin'
  params: {
    // Required parameters
    name: logAnalyticsName
    // Non-required parameters
    location: location
    dataRetention: 60
    skuName: 'PerGB2018'
  }
}

// resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
//   name: 'SecurityInsights(${logAnalyticsName})'
//   dependsOn: [workspace]
//   location: location
//   properties: {
//     workspaceResourceId: workspace.outputs.resourceId
//   }
//   plan: {
//     name: 'SecurityInsights(${logAnalyticsName})'
//     product: 'OMSGallery/SecurityInsights'
//     promotionCode: ''
//     publisher: 'Microsoft'
//   }
// }

@description('The resource ID of the created Workspace.')
output workspaceId string = workspace.outputs.resourceId
