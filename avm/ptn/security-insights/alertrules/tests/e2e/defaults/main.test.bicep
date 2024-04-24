targetScope = 'subscription'
metadata name = 'Security Insights - Alert Rules Default Configuration'
metadata description = 'Implement alert rules for Security Insights using a default configuration.'
metadata owner = 'InnofactorOrg/module-maintainers'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
// e.g., for a module 'network/private-endpoint' you could use 'dep-dev-network.privateendpoints-${serviceShort}-rg'
param resourceGroupName string = 'dep-${namePrefix}-securityinsights-alertrules-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
// e.g., for a module 'network/private-endpoint' you could use 'npe' as a prefix and then 'waf' as a suffix for the waf-aligned test
param serviceShort string = 'csocmin'

@description('Optional. A token to inject into the name of each resource. This value can be automatically injected by the CI.')
param namePrefix string = '#_namePrefix_#'

@description('Optional. An array of rules to deploy for Azure Sentinel.')
param rules array = [
  {
    displayName: 'Failed login attempts to Azure Portal'
    description: '''
   'Identifies failed login attempts in the Microsoft Entra ID SigninLogs to the Azure Portal.  Many failed logon
  attempts or some failed logon attempts from multiple IPs could indicate a potential brute force attack.
  The following are excluded due to success and non-failure results:
  References: https://docs.microsoft.com/azure/active-directory/reports-monitoring/reference-sign-ins-error-codes
  0 - successful logon
  50125 - Sign-in was interrupted due to a password reset or password registration entry.
  50140 - This error occurred due to 'Keep me signed in' interrupt when the user was signing-in.'
   '''
    query: '''
   let timeRange = 1d;
  let lookBack = 7d;
  let threshold_Failed = 1;
  let threshold_FailedwithSingleIP = 20;
  let threshold_IPAddressCount = 2;
  let isGUID = "[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}";
  let aadFunc = (tableName:string){
  let azPortalSignins = materialize(table(tableName)
  | where TimeGenerated >= ago(lookBack)
  // Azure Portal only
  | where AppDisplayName =~ "Azure Portal")
  ;
  let successPortalSignins = azPortalSignins
  | where TimeGenerated >= ago(timeRange)
  // Azure Portal only and exclude non-failure Result Types
  | where ResultType in ("0", "50125", "50140")
  // Tagging identities not resolved to friendly names
  //| extend Unresolved = iff(Identity matches regex isGUID, true, false)
  | distinct TimeGenerated, UserPrincipalName
  ;
  let failPortalSignins = azPortalSignins
  | where TimeGenerated >= ago(timeRange)
  // Azure Portal only and exclude non-failure Result Types
  | where ResultType !in ("0", "50125", "50140", "70044", "70043")
  // Tagging identities not resolved to friendly names
  | extend Unresolved = iff(Identity matches regex isGUID, true, false)
  ;
  // Verify there is no success for the same connection attempt after the fail
  let failnoSuccess = failPortalSignins | join kind= leftouter (
     successPortalSignins
  ) on UserPrincipalName
  | where TimeGenerated > TimeGenerated1 or isempty(TimeGenerated1)
  | project-away TimeGenerated1, UserPrincipalName1
  ;
  // Lookup up resolved identities from last 7 days
  let identityLookup = azPortalSignins
  | where TimeGenerated >= ago(lookBack)
  | where not(Identity matches regex isGUID)
  | summarize by UserId, lu_UserDisplayName = UserDisplayName, lu_UserPrincipalName = UserPrincipalName;
  // Join resolved names to unresolved list from portal signins
  let unresolvedNames = failnoSuccess | where Unresolved == true | join kind= inner (
     identityLookup
  ) on UserId
  | extend UserDisplayName = lu_UserDisplayName, UserPrincipalName = lu_UserPrincipalName
  | project-away lu_UserDisplayName, lu_UserPrincipalName;
  // Join Signins that had resolved names with list of unresolved that now have a resolved name
  let u_azPortalSignins = failnoSuccess | where Unresolved == false | union unresolvedNames;
  u_azPortalSignins
  | extend DeviceDetail = todynamic(DeviceDetail), Status = todynamic(DeviceDetail), LocationDetails = todynamic(LocationDetails)
  | extend Status = strcat(ResultType, ": ", ResultDescription), OS = tostring(DeviceDetail.operatingSystem), Browser = tostring(DeviceDetail.browser)
  | extend State = tostring(LocationDetails.state), City = tostring(LocationDetails.city), Region = tostring(LocationDetails.countryOrRegion)
  | extend FullLocation = strcat(Region,'|', State, '|', City)
  | summarize TimeGenerated = make_list(TimeGenerated,100), Status = make_list(Status,100), IPAddresses = make_list(IPAddress,100), IPAddressCount = dcount(IPAddress), FailedLogonCount = count()
  by UserPrincipalName, UserId, UserDisplayName, AppDisplayName, Browser, OS, FullLocation, Type
  | mvexpand TimeGenerated, IPAddresses, Status
  | extend TimeGenerated = todatetime(tostring(TimeGenerated)), IPAddress = tostring(IPAddresses), Status = tostring(Status)
  | project-away IPAddresses
  | summarize StartTime = min(TimeGenerated), EndTime = max(TimeGenerated) by UserPrincipalName, UserId, UserDisplayName, Status, FailedLogonCount, IPAddress, IPAddressCount, AppDisplayName, Browser, OS, FullLocation, Type
  | where (IPAddressCount >= threshold_IPAddressCount and FailedLogonCount >= threshold_Failed) or FailedLogonCount >= threshold_FailedwithSingleIP
  | extend timestamp = StartTime, Name = tostring(split(UserPrincipalName,'@',0)[0]), UPNSuffix = tostring(split(UserPrincipalName,'@',1)[0])
  };
  let aadSignin = aadFunc("SigninLogs");
  let aadNonInt = aadFunc("AADNonInteractiveUserSignInLogs");
  union isfuzzy=true aadSignin, aadNonInt
   '''
    queryPeriod: 'PT5M'
    queryFrequency: 'PT5M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    severity: 'High'
    suppressionEnabled: false
    suppressionDuration: 'PT1H'
    enabled: true
    tactics: [
      'CredentialAccess'
    ]
    techniques: [
      'T1110'
    ]
    entityMappings: [
      {
        entityType: 'Account'
        fieldMappings: [
          {
            identifier: 'Name'
            columnName: 'Name'
          }
          {
            identifier: 'UPNSuffix'
            columnName: 'UPNSuffix'
          }
        ]
      }
      {
        entityType: 'IP'
        fieldMappings: [
          {
            identifier: 'Address'
            columnName: 'IPAddress'
          }
        ]
      }
    ]
    alertRuleTemplateName: '223db5c1-1bf8-47d8-8806-bed401b356a4'
    templateVersion: '1.0.4'
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

// Dependencies for the module
// ===========================

// Deploy some diagnostics resources for the module use in the test
module diagnostics '../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}azsa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-${namePrefix}-evhns-${serviceShort}'
    location: resourceLocation
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
      // You parameters go here
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      sentinelWorkspaceId: diagnostics.outputs.logAnalyticsWorkspaceResourceId
      rules: rules
    }
  }
]
