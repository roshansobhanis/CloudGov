provider "azurerm" {
  version = "~> 2.7"
  subscription_id = var.client_subscription_id
  features {}
}


# the subscription_id here always stays the same all private dns zones are created in the identity westeurope subscription 
provider "azurerm" {
  alias = "secondary"
  version = "~> 2.7"
  subscription_id = "83761e2e-9076-4a49-9148-6b3c4a667d10"
  features {}
}

provider "azuread" {
  version = "~> 1.4.0"
}

provider "random" {
  version = "~> 2.3"
}

locals {
    region = module.subscription.region
    application_code = var.application_code
    environment = var.environment
    rg_name =  join("-",concat(["rg","${module.subscription.project_name}","${module.subscription.environment}","${var.app_tier}","${module.subscription.region}"]))
    name_part = "${local.application_code}-${local.environment}"
    sa_name = "sa${local.application_code}${local.environment}dlsa"
    dlfs_name = "dlfsg2${local.application_code}${local.environment}"
    nic_tier_subnet = "${lower(var.app_tier) == "apptier" ? "application" : "${lower(var.app_tier)}"}"
    subnet_name = "SNET-${local.nic_tier_subnet}"
    route_table_name = "rt-${module.subscription.project_name}-${module.subscription.environment}-${local.region}"
    #admins_group = replace(module.subscription.sql_admin_AAD_group, "DBAs", "Admins")
    admins_group = "Azure - ${module.subscription.business_unit} - ${module.subscription.environment} - ${module.subscription.project_name} - Admins"
    #admins_group_workaround = "Azure - Platform - prod - policytest - Admins"
}

module "subscription" {
  source = "git::git@ssh.dev.azure.com:v3/RB-Group/RB.Cloud.Library/library.azure.subscriptionbyid"
  subscription_id = var.client_subscription_id
}

data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

data "azurerm_key_vault" "key_vault" {
   name                = module.subscription.baseinfra_kv_name
   resource_group_name = module.subscription.baseinfra_rgname
}

data "azurerm_virtual_network" "vnet" {
  name                = module.subscription.vnet_name
  resource_group_name = module.subscription.vnet_rg
}

data "azurerm_subnet" "subnet" {
    name                 = local.subnet_name
    resource_group_name  = module.subscription.vnet_rg
    virtual_network_name = module.subscription.vnet_name
}

data "azuread_group" "admin_group" {
  display_name = local.admins_group
}

data "azurerm_route_table" "our_rt" {
  name                = local.route_table_name
  resource_group_name = module.subscription.vnet_rg
}

data "azurerm_private_dns_zone" "westeurope" {
  provider = azurerm.secondary
  name                = "privatelink.${local.region}.azmk8s.io"
  resource_group_name = "rg-platform-identity-privatedns-${local.region}"
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks-${local.application_code}-${local.environment}-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = local.region
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = data.azurerm_route_table.our_rt.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "dns_contributor" {
  scope                = data.azurerm_private_dns_zone.westeurope.id
  role_definition_name = "Private Dns Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "vm_contributor" {
  scope                = data.azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}


resource "azurerm_kubernetes_cluster" "kube_cluster" {
  name                = lower("azaks-${local.application_code}-${local.environment}")
  location            = local.region
  resource_group_name = data.azurerm_resource_group.rg.name

  # must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens.
  dns_prefix          = lower("azaks-${local.application_code}-${local.environment}-kube")
  private_cluster_enabled = true

  private_dns_zone_id = data.azurerm_private_dns_zone.westeurope.id

  # possible values: Free, Paid
  sku_tier = var.sku_tier 
  tags = {
    "module" = "library.azure.aks"
  }

  addon_profile {
    azure_policy {
      enabled = true
    }
    kube_dashboard {
      enabled = var.kube_dashboard
    }
  }

  # role based access control
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      admin_group_object_ids = [data.azuread_group.admin_group.object_id]
    }
  }

  # network - kubenet
  network_profile {
    network_plugin = "kubenet"
    outbound_type = "userDefinedRouting"
  }

  # user assigned managed identity
  # since clusters using managed identity type SystemAssigned do not support bringing your own route table.
  identity {
    type = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks.id
  }

  # default_node_pool.0.name must start with a lowercase letter, have max length of 12, and only have characters a-z0-9.
  default_node_pool {
    name       = "default"
    enable_auto_scaling = var.auto_scaling
    type = "VirtualMachineScaleSets"

    # can either be Ephemeral or Managed
    os_disk_type = var.os_disk_type

    # must be from 1 to 1000
    node_count = var.node_count
    max_count = var.auto_scaling == true ? var.max_count : null
    min_count = var.auto_scaling == true ? var.min_count : null
    vm_size    = var.vm_size
    vnet_subnet_id = data.azurerm_subnet.subnet.id
  }

lifecycle {
  ignore_changes = [
    tags,
    default_node_pool
  ]
}

depends_on = [ azurerm_role_assignment.dns_contributor, azurerm_role_assignment.network_contributor, azurerm_role_assignment.vm_contributor ]


}

resource "azurerm_key_vault_secret" "kube_admin_client_key" {
    name         = "azaks-${local.application_code}-${local.environment}-clientKey"
    value        = azurerm_kubernetes_cluster.kube_cluster.kube_admin_config.0.client_key
    key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "kube_admin_client_cert" {
    name         = "azaks-${local.application_code}-${local.environment}-clientCertificate"
    value        = azurerm_kubernetes_cluster.kube_cluster.kube_admin_config.0.client_certificate
    key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "kube_admin_cluster_ca_certificate" {
    name         = "azaks-${local.application_code}-${local.environment}-clusterCaCertificate"
    value        = azurerm_kubernetes_cluster.kube_cluster.kube_admin_config.0.cluster_ca_certificate
    key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "kube_admin_password" {
    name         = "azaks-${local.application_code}-${local.environment}-Password"
    value        = azurerm_kubernetes_cluster.kube_cluster.kube_admin_config.0.password
    key_vault_id = data.azurerm_key_vault.key_vault.id
}
