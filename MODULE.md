## Requirements

| Name | Version |
|------|---------|
| azurerm | ~> 2.7 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 2.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| subscription | git::git@ssh.dev.azure.com:v3/RB-Group/RB.Cloud.Library/library.azure.subscription |  |

## Resources

| Name |
|------|
| [azurerm_container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/2.7/docs/resources/container_registry) |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/2.7/docs/data-sources/resource_group) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_tier | The application tier. Allowed values: FrontEnd \| BackEnd \| AppTier | `string` | n/a | yes |
| application\_code | The name of the application that is being deployed. Ex. GLM \| VLL | `string` | n/a | yes |
| environment | The environment type that is being deployed.  Allowed Values: Prod \| Dev \| QA \| Test | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| registry\_id | The ID of the Container Registry |
| registry\_logon\_url | The URL that can be used to log into the container registry. |
| registry\_name | The name of the Container Registry |