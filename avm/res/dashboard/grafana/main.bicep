metadata name = 'Azure Grafana Dashboard'
metadata description = 'This module deploys an Azure Grafana Dashboard.'
metadata owner = 'InnofactorOrg/module-maintainers'

@description('Required. Name of your Azure Grafana Dashboard.')
@minLength(5)
@maxLength(50)
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Tier of your Azure Grafana Dashboard.')
@allowed([
  'Standard'
])
param grafanaSku string = 'Standard'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Whether or not zone redundancy is enabled for this Grafana dashboard.')
param zoneRedundancy string = 'Disabled'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. The api key setting of the Grafana instance.')
param apiKey string = 'Disabled'

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkRuleSetIpRules are not set.  Note, requires the \'acrSku\' to be \'Premium\'.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string?

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Whether a Grafana instance uses deterministic outbound IPs for this instancey.')
param deterministicOutboundIP string = 'Disabled'

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

//
// Add your parameters here
//

// ============== //
// Resources      //
// ============== //

resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' =
  if (enableTelemetry) {
    name: '46d3xbcp.res.dashboard-grafana.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
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

resource grafana 'Microsoft.Dashboard/grafana@2023-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: grafanaSku
  }
  properties: {
    zoneRedundancy: grafanaSku == 'Standard' ? zoneRedundancy : null
    publicNetworkAccess: !empty(publicNetworkAccess) ? any(publicNetworkAccess) : null
    apiKey: grafanaSku == 'Standard' ? apiKey : null
    deterministicOutboundIP: grafanaSku == 'Standard' ? deterministicOutboundIP : null
  }
}

// ============ //
// Outputs      //
// ============ //

// Add your outputs here

@description('The Name of the Azure Grafana Dashboard.')
output name string = grafana.name

@description('The reference to the Azure Grafana Dashboard.')
output loginServer string = grafana.properties.endpoint

@description('The name of the Azure Grafana Dashboard.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the Azure Grafana Dashboard.')
output resourceId string = grafana.id

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = grafana.?identity.?principalId ?? ''

@description('The location the resource was deployed into.')
output location string = grafana.location

// ================ //
// Definitions      //
// ================ //
//
// Add your User-defined-types here, if any
//
