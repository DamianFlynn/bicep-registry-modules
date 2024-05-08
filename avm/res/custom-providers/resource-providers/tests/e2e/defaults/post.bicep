@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

@description('Required. The name of the Custom Resource Provider.')
param name string

@description('Optional. Tags to apply to the resources.')
param tags object = {}

// The sample application and resources in the custom provider is offering a resource called 'users'
var customProviderResourceName = '${name}/users'

resource customProviderUser1 'Microsoft.CustomProviders/resourceProviders/users@2018-09-01-preview' = {
  name: '${customProviderResourceName}/user1'
  location: location
  tags: tags
  properties: {
    FullName: 'Mystic'
    Location: 'Mayo'
  }
}

//
// Actions Outputs
//

// Actions listed in the Custom RP must be named as follows: list<actionName>
// Following this nameing requirement, Azure ARM Functions can be called to execute the action
// The following Outputs are examples of how to call the actions

// var functionValues = {
//   myProperty1: 'myPropertyValue1'
//   myProperty2: {
//     myProperty3: 'myPropertyValue3'
//   }
// }

// output customActionObject object = listMyCustomAction(testDeployment[0].id, '2018-09-01-preview', functionValues)
// output customActionListSubObject object = listSubscriptions(testDeployment[0].id, '2018-09-01-preview', functionValues)
// output customActionListSubPropertyRandom string = listSubscriptions(
//   testDeployment[0].id,
//   '2018-09-01-preview',
//   functionValues
// ).listMyActionResult.randomString

// These outputs can also be verified using the following REST API Tests
//
// listMyCustomAction
// listURI="https://management.azure.com/subscriptions/83264035-996f-4ca6-b71e-c534333d0ccf/resourceGroups/p-gov-crp/providers/Microsoft.CustomProviders/resourceProviders/jarvis20240507/listMyCustomAction?api-version=2018-09-01-preview"
// az rest --method post --uri $listURI
//
// listSubscriptions Action
// listSubsURI="https://management.azure.com/subscriptions/83264035-996f-4ca6-b71e-c534333d0ccf/resourceGroups/p-gov-crp/providers/Microsoft.CustomProviders/resourceProviders/jarvis20240507/listSubscriptions?api-version=2018-09-01-preview"
// az rest --method post --uri $listSubsURI

//
// Resource Outputs
//

output varCustomProviderResourceName string = customProviderResourceName
output myUsersObject object = customProviderUser1
output myUsersObjectName string = customProviderUser1.properties.randomString

// Test using REST API
//
// usersURI="https://management.azure.com/subscriptions/83264035-996f-4ca6-b71e-c534333d0ccf/resourceGroups/p-gov-crp/providers/Microsoft.CustomProviders/resourceProviders/jarvis20240507/users/user1?api-version=2018-09-01-preview"
// az rest --method post --uri $listSubsURI
