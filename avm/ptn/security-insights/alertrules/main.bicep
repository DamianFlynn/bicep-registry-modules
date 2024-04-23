metadata name = 'Sentinel Rules Deployment'
metadata description = 'The Pattern will deploy Sentinel Rules to a Log Analytics Workspace.'
metadata owner = 'Innofactor/Azure-Modules'

// @description('Required. Name of the resource to create.')
// param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Required. The ID of the Log Analytics workspace.')
param workspaceId string

@description('Optional. An array of rule objects to deploy.')
param rules array = [{}]

//
// Add your parameters here
//

// ============== //
// Resources      //
// ============== //

resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' =
  if (enableTelemetry) {
    name: '46d3xbcp.innofactor-ptn-sentinel-rules.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
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

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  name: workspaceId
}

resource deployedRules 'Microsoft.SecurityInsights/alertRules@2023-02-01-preview' = [
  for (rule, index) in rules: {
    name: rule.displayName
    scope: workspace // Directly use the workspace resource as the scope
    kind: 'Scheduled'
    properties: rule
  }
]

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

// @description('The resource ID of the resource.')
// output resourceId string = <Resource>.id

// @description('The name of the resource.')
// output name string = <Resource>.name

// @description('The location the resource was deployed into.')
// output location string = <Resource>.location

// ================ //
// Definitions      //
// ================ //
//
// Add your User-defined-types here, if any
//

// Define a user-defined type for the failedLogonToAzurePortal resource

// Define a user-defined type for entity mapping field
type FieldMapping = {
  identifier: string
  columnName: string
}

// Define a user-defined type for entity mappings
type EntityMapping = {
  entityType: string
  fieldMappings: FieldMapping[]
}

// Define a user-defined type for the rule
type Rule = {
  displayName: string
  description: string
  query: string
  queryPeriod: string
  queryFrequency: string
  triggerOperator: string
  triggerThreshold: int
  severity: string
  suppressionEnabled: bool
  suppressionDuration: string
  enabled: bool
  tactics: string[]
  techniques: string[]
  entityMappings: EntityMapping[]
  alertRuleTemplateName: string
  templateVersion: string
}
