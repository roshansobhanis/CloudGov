## Requirements

| Name | Version |
|------|---------|
| azuread | ~> 1.4.0 |
| azurerm | ~> 2.7 |
| azurerm | ~> 2.7 |
| random | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| azuread | ~> 1.4.0 |
| azurerm | ~> 2.7 ~> 2.7 |
| azurerm.secondary | ~> 2.7 ~> 2.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| subscription | git::git@ssh.dev.azure.com:v3/RB-Group/RB.Cloud.Library/library.azure.subscriptionbyid |  |

## Resources

| Name |
|------|
| [azuread_group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) |
| [azurerm_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) |
| [azurerm_key_vault_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) |
| [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) |
| [azurerm_private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) |
| [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) |
| [azurerm_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/route_table) |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) |
| [azurerm_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) |
| [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_tier | The application tier. Allowed values: FrontEnd \| BackEnd \| AppTier | `string` | n/a | yes |
| application\_code | The name of the application that is being deployed. Ex. GLM \| VLL | `string` | n/a | yes |
| auto\_scaling | Should the Kubernetes Auto Scaler be enabled for this Node Pool? Default is false | `bool` | `false` | no |
| client\_subscription\_id | The target client subscription to create the AKS cluster | `string` | n/a | yes |
| environment | The environment type that is being deployed.  Allowed Values: Prod \| Dev \| QA \| Test | `string` | n/a | yes |
| host\_encryption | Should the nodes in the Default Node Pool have host encryption enabled? Default is false | `bool` | `false` | no |
| kube\_dashboard | Is the Kubernetes Dashboard enabled? | `bool` | `true` | no |
| max\_count | Takes place only if ENABLE\_AUTO\_SCALING = TRUE; The maximum number of nodes which should exist in this Node Pool. Defaults to 5. Can't be less than node\_count. | `number` | `3` | no |
| min\_count | Takes place only if ENABLE\_AUTO\_SCALING = TRUE; The minimum number of nodes which should exist in this Node Pool. Default is 1. Can't be greater than node\_count. | `number` | `1` | no |
| node\_count | The initial number of nodes which should exist in this Node Pool. Must be between 1 and 1000 | `number` | `2` | no |
| os\_disk\_type | The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. | `string` | `"Managed"` | no |
| sku\_tier | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid. The default value if free. | `string` | `"Free"` | no |
| vm\_size | The size of the Virtual Machine | `string` | `"Standard_D2_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| aks\_fqdn | AKS cluster FQDN |
| aks\_id | AKS cluster id |
| kube\_admin\_config\_hostname | n/a |
| kube\_admin\_config\_username | n/a |
| kubelet\_identity\_client\_id | n/a |
| kubelet\_identity\_object\_id | n/a |
| master\_principal\_id | AKS Managed Identity service principal ID |
| master\_tenant\_id | AKS Managed Identity service principal ID |
| node\_resource\_group | Newly created node resource group name where all components will be located |