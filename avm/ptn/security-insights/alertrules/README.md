# Sentinel Rules Deployment `[Microsoft.SecurityInsights/alertRules]`

The Pattern will deploy Sentinel Rules to a Log Analytics Workspace.

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
| `Microsoft.SecurityInsights/alertRules` | [2023-02-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.SecurityInsights/2023-02-01-preview/alertRules) |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/ptn/security-insights/alertrules:<version>`.

- [Default Usage Scenario](#example-1-default-usage-scenario)
- [WAF Usage Scenario](#example-2-waf-usage-scenario)

### Example 1: _Default Usage Scenario_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module alertrules 'br/public:avm/ptn/security-insights/alertrules:<version>' = {
  name: 'alertrulesDeployment'
  params: {
    // Required parameters
    workspaceId: '<workspaceId>'
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
    "workspaceId": {
      "value": "<workspaceId>"
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

### Example 2: _WAF Usage Scenario_

This instance deploys the module with WAF features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module alertrules 'br/public:avm/ptn/security-insights/alertrules:<version>' = {
  name: 'alertrulesDeployment'
  params: {
    // Required parameters
    workspaceId: '<workspaceId>'
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
    "workspaceId": {
      "value": "<workspaceId>"
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
| [`workspaceId`](#parameter-workspaceid) | string | The ID of the Log Analytics workspace. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`rules`](#parameter-rules) | array | An array of rule objects to deploy. |

### Parameter: `workspaceId`

The ID of the Log Analytics workspace.

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

An array of rule objects to deploy.

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    {}
  ]
  ```


## Outputs

| Output | Type |
| :-- | :-- |

## Cross-referenced modules

_None_

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
