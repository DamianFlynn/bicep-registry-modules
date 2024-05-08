targetScope = 'subscription'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-customrp-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = 'westeurope' //deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'dbgmin'

@description('Optional. A token to inject into the name of each resource. This value can be automatically injected by the CI.')
param namePrefix string = 'custrp' //'#_namePrefix_#'

//
// Custom RP parameters
//
@description('Optional. The name of the function app to deploy.')
param functionAppName string = 'dep-${namePrefix}-fn-${serviceShort}'

@description('Optional. The URI of the zip file containing the function code.')
param zipFileBlobUri string = 'https://github.com/Azure/azure-custom-providers/blob/master/SampleFunctions/CSharpSimpleProvider/Artifacts/functionZip/functionpackage.zip?raw=true'

@description('Optional. Actions of the resource as published in the Function Code.')
param actions array = [
  {
    name: 'ping'
    routingType: 'Proxy'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
  {
    name: 'listMyCustomAction'
    routingType: 'Proxy'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
  {
    name: 'listSubscriptions'
    routingType: 'Proxy'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
]

@description('Optional. Resource Types of the resource as published in the function code.')
param resourceTypes array = [
  {
    name: 'users'
    routingType: 'Proxy,Cache'
    endpoint: 'https://${functionAppName}.azurewebsites.net/api/{requestPath}'
  }
]

@description('Optional. Validations endpoints of the resource matching swagger for the code.')
param validations array = [
  {
    validationType: 'swagger'
    specification: 'https://raw.githubusercontent.com/Azure/azure-custom-providers/master/CustomRPWithSwagger/Artifacts/Swagger/pingaction.json'
  }
  {
    validationType: 'swagger'
    specification: 'https://raw.githubusercontent.com/Azure/azure-custom-providers/master/CustomRPWithSwagger/Artifacts/Swagger/userresource.json'
  }
]

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    location: resourceLocation
    functionAppName: functionAppName
    zipFileBlobUri: zipFileBlobUri
    tags: {
      'hidden-title': 'This is visible in the resource name'
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      actions: actions
      resourceTypes: resourceTypes
      // validations: validations
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
  }
]

// Post Resource Deployment Validations

module postDeploymentVerification 'post.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-postValidations'
  params: {
    name: testDeployment[0].outputs.resourceId
    location: resourceLocation
    tags: {
      'hidden-title': 'This is visible in the resource name'
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
  dependsOn: [
    testDeployment
  ]
}
