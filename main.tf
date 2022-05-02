provider "azurerm" {
  version = "~> 2.7"
  features {}
}

locals {
    region = module.subscription.region
    environment = module.subscription.environment
    rg_name =  join("-",concat(["rg", module.subscription.project_name, module.subscription.environment, var.app_tier, module.subscription.region]))
    project_name = module.subscription.project_name 
    acr_name = lower("acr${var.application_code}${var.environment}${local.region}")
}

module "subscription" {
  source = "git::git@ssh.dev.azure.com:v3/RB-Group/RB.Cloud.Library/library.azure.subscription"
}

data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

# resource naming: 
# acrprojectnameenvironmentregion
resource "azurerm_container_registry" "acr" {
  name                     = local.acr_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = local.region
  sku                      = "Premium"
  admin_enabled            = false
  trust_policy = [ {
    enabled = true
  } ] 
  tags = {
    module  = "library.azure.acr"
  }

}
