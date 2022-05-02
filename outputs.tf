output "aks_id" {
    value = azurerm_kubernetes_cluster.kube_cluster.id
    description = "AKS cluster id"
}

output "aks_fqdn" {
    value = azurerm_kubernetes_cluster.kube_cluster.fqdn
    description = "AKS cluster FQDN"
}

output "node_resource_group" {
    value = azurerm_kubernetes_cluster.kube_cluster.node_resource_group
    description = "Newly created node resource group name where all components will be located"
}

output "master_principal_id" {
    value = azurerm_kubernetes_cluster.kube_cluster.identity.0.principal_id
    description = "AKS Managed Identity service principal ID"
}

output "master_tenant_id" {
    value = azurerm_kubernetes_cluster.kube_cluster.identity.0.tenant_id
    description = "AKS Managed Identity service principal ID"
}

output "kubelet_identity_client_id" {
    value = azurerm_kubernetes_cluster.kube_cluster.kubelet_identity.0.client_id
}

output "kubelet_identity_object_id" {
    value = azurerm_kubernetes_cluster.kube_cluster.kubelet_identity.0.object_id
}

output "kube_admin_config_hostname" {
    value = azurerm_kubernetes_cluster.kube_cluster.kube_admin_config.0.host
}

output "kube_admin_config_username" {
    value = azurerm_kubernetes_cluster.kube_cluster.kube_admin_config.0.username
}
