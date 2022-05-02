output "registry_id" {
    value       = azurerm_container_registry.acr.id
    description = "The ID of the Container Registry"
}

output "registry_name" {
    value       = azurerm_container_registry.acr.name
    description = "The name of the Container Registry"
}

output "registry_logon_url" {
    value       = azurerm_container_registry.acr.login_server
    description = "The URL that can be used to log into the container registry."
}