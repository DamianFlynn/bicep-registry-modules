# Security Insights - Alert Rules `[Microsoft.SecurityInsights/alertRules]`

Implement alert rules for Security Insights

## Navigation

- [Resource Types](#Resource-Types)
- [Usage examples](#Usage-examples)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Data Collection](#Data-Collection)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.OperationsManagement/solutions` | [2015-11-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationsManagement/2015-11-01-preview/solutions) |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/ptn/security-insights/alertrules:<version>`.

- [Security Insights - Alert Rules Default Configuration](#example-1-security-insights---alert-rules-default-configuration)
- [Security Insights - Alert Rules Well Architected Configuration](#example-2-security-insights---alert-rules-well-architected-configuration)

### Example 1: _Security Insights - Alert Rules Default Configuration_

Implement alert rules for Security Insights using a default configuration.


<details>

<summary>via Bicep module</summary>

```bicep
module alertrules 'br/public:avm/ptn/security-insights/alertrules:<version>' = {
  name: 'alertrulesDeployment'
  params: {
    // Required parameters
    name: 'csocmin001'
    sentinelWorkspaceId: '<sentinelWorkspaceId>'
    // Non-required parameters
    location: '<location>'
    rules: '<rules>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "csocmin001"
    },
    "sentinelWorkspaceId": {
      "value": "<sentinelWorkspaceId>"
    },
    // Non-required parameters
    "location": {
      "value": "<location>"
    },
    "rules": {
      "value": "<rules>"
    }
  }
}
```

</details>
<p>

### Example 2: _Security Insights - Alert Rules Well Architected Configuration_

Implement alert rules for Security Insights using a WAF Compliant configuration.


<details>

<summary>via Bicep module</summary>

```bicep
module alertrules 'br/public:avm/ptn/security-insights/alertrules:<version>' = {
  name: 'alertrulesDeployment'
  params: {
    // Required parameters
    name: 'csocwaf001'
    sentinelWorkspaceId: '<sentinelWorkspaceId>'
    // Non-required parameters
    location: '<location>'
    rules: '<rules>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "name": {
      "value": "csocwaf001"
    },
    "sentinelWorkspaceId": {
      "value": "<sentinelWorkspaceId>"
    },
    // Non-required parameters
    "location": {
      "value": "<location>"
    },
    "rules": {
      "value": "<rules>"
    }
  }
}
```

</details>
<p>


## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | Name of the resource to create. |
| [`sentinelWorkspaceId`](#parameter-sentinelworkspaceid) | string | The workspace ID of the Sentinel workspace we will be working with. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`rules`](#parameter-rules) | array | An array of alert rules to create. |

### Parameter: `name`

Name of the resource to create.

- Required: Yes
- Type: string

### Parameter: `sentinelWorkspaceId`

The workspace ID of the Sentinel workspace we will be working with.

- Required: Yes
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `location`

Location for all Resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `rules`

An array of alert rules to create.

- Required: No
- Type: array
- Default: `[]`


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the resource. |
| `resourceGroupName` | string | The resource group of the resource. |
| `resourceId` | string | The resource ID of the resource. |

## Cross-referenced modules

_None_

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
