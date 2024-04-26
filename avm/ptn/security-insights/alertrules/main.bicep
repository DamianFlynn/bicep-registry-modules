metadata name = 'Security Insights - Alert Rules'
metadata description = 'Implement alert rules for Security Insights'
metadata owner = 'InnofactorOrg/module-maintainers'

@description('Required. Name of the resource to create.')
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

//
// Add your parameters here
//

@description('Required. The workspace ID of the Sentinel workspace we will be working with.')
param sentinelWorkspaceId string

@description('Optional. An array of alert rules to create.')
param rules array = []

// ============== //
// Resources      //
// ============== //

resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' =
  if (enableTelemetry) {
    name: '46d3xbcp.securityinsights-alertrules.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
    properties: {
      mode: 'Incremental'
      template: {
        '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
        contentVersion: '1.0.0.0'
        resources: []
        outputs: {
          telemetry: {
            type: 'String'
            value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
          }
        }
      }
    }
  }

//
// Add your resources here
//

// Get the existing Sentinel workspace

resource sentinelWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing =
  if (!empty(sentinelWorkspaceId) && !empty(rules)) {
    name: last(split((!empty(sentinelWorkspaceId) ? sentinelWorkspaceId : 'law'), '/'))!
  }

// Ensure we have the sentinel solution

resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' =
  if (!empty(sentinelWorkspaceId) && !empty(rules)) {
    name: 'SecurityInsights(${sentinelWorkspace.name})'
    location: location
    properties: {
      workspaceResourceId: sentinelWorkspace.id
    }
    plan: {
      name: 'SecurityInsights(${sentinelWorkspace.name})'
      product: 'OMSGallery/SecurityInsights'
      promotionCode: ''
      publisher: 'Microsoft'
    }
  }

// Deploy rules

resource scheduledAlertRules 'Microsoft.SecurityInsights/alertRules@2023-02-01-preview' = [
  for (rule, index) in rules: {
    name: rule.id
    scope: sentinelWorkspace
    dependsOn: [sentinel]
    kind: 'Scheduled'
    properties: rule.properties
  }
]

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

@description('The resource ID of the resource.')
output resourceId string = sentinelWorkspace.id

@description('The resource group of the resource.')
output resourceGroupName string = resourceGroup().name

@description('The name of the resource.')
output name string = sentinelWorkspace.name

@description('The location the resource was deployed into.')
output location string = sentinelWorkspace.location

// ================ //
// Definitions      //
// ================ //
//
// Add your User-defined-types here, if any
//
