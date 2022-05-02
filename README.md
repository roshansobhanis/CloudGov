- [Introduction](#introduction)
- [Module-specific Features](#module-specific-features)
  - [Prerequisites](#prerequisites)
  - [Build Guide](#technical-architecture)
    - [Contents Overview](#contents-overview)
    - [Outputs and Secrets](#outputs-and-secrets)
    - [Ephemeral OS](#ephemeral-os)
    - [Connecting to a Private Cluster](#connecting-to-a-private-cluster)
  - [Common Errors](#service-configuration)
- [Example Usage](#example-usage)
---

# Introduction 

This module builds an AKS cluster on demand for the users.   
Currently only the RBCloud Team members have permissions to create new AKS clusters, due to the security guidelines of the company.
Therefore we strongly recommend to contact us with your AKS creations request.

The prime target audience of this README is RBCloud Team. 

# Module-specific features

- The AKS cluster is private, uses a pre-defined private DNS Zone. Each region contains its own pre-defined private DNS Zone in the form of ``` privatelink.region.azmk8s.io ```. - please refer to https://docs.microsoft.com/en-us/azure/aks/private-clusters#hub-and-spoke-with-custom-dns.
- Our AKS cluster uses kubenet networking. With kubenet, nodes get an IP address from the Azure virtual network subnet. Pods receive an IP address from a logically different address space to the Azure virtual network subnet of the nodes. Network address translation (NAT) is then configured so that the pods can reach resources on the Azure virtual network. The source IP address of the traffic is NAT'd to the node's primary IP address. This approach greatly reduces the number of IP addresses that you need to reserve in your network space for pods to use. - please refer to https://docs.microsoft.com/en-us/azure/aks/configure-kubenet. 
- Kubenet networking supports running on LINUX only,so the usage of Windows here is strongly discouraged, requires a very strong reason and almost complete code customisation.
- There are several features that may be configured in the module: using managed or unmanaged disk type, autoscaling and its options and sku tier. The variables description in MODULE.md describes the possible input variables. For the complete terraform guide please refer to https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster. 

## Prerequisites 

- Make sure that you've read the official Microsoft Azure documentation: https://docs.microsoft.com/en-us/azure/aks/;
- Make sure that the private dns zone in a form ``` privatelink.region.azmk8s.io ``` is available and the conditional forwarders have been created;
- Make sure that the policy initiative ``` Initiative-PrivateDNSZonePolicies ``` contains the policy ``` Deploy-PrivateDnsZone-Record ``` with the reference id ``` Deploy-PrivateDnsZone-management-<region> ```;
- Prepare the ``` subscription id ``` of the target subscription;
- Be aware that AKS creates its own resource group in the subscription, where all k8s related resources are stored. The name of this resource group (when not explicitly specified)will be following the pattern: ``` MC_<aks cluster resource group>_<aks cluster name>_<region> ```. The default naming can be changed by adding a parameter ``` node_resource_group = <custom name here>``` to the ``` azurerm_kubernetes_cluster ``` confuguration. Keep in mind that the name must be unique and the resource group should not exist prior to AKS deployment;
- Make sure to request the Owner role over the ``` Platform-Identity-Prod-WestEurope ``` through PIM, as this is required for successfuk module deployment (see below why).


## Build Guide

### Contents Overview

The ``` library.azure.aks ``` creates an ``` azurerm_kubernetes_cluster ``` as a main resource aliog with a user-assigned managed identity, that is further assigned to the cluster.  Several role assignments have to be granted to the managed identity, to successfully operate the cluster. 

The first step is to create a user-assigned managed identity for the AKS cluster to assign to.   
This managed identity has to have several roles granted over specific resources: 
- A Network Contributor role on the client's subscription route table;
- A Private DNS Zone contibutor role on the private DNS zone of that region. Private DNS Zones reside in ``` Platform-Identity-Prod-WestEurope ``` subscription, so you need to be an owner on this subscription;  
Once the roles have been successfully assigned, the kubernetes cluster is being created. Normally it takes around 8-10 minutes to create it. No errors to be expected here. 

The default node pool ``` node_count = 2 ```. 

Autoscaling: when enabled, the default ```max_node_count = 3```, ```min_node_count = 1```. These values can be confgured through the corresponding variables, but the following must always be true: 
- ```max_node_count > node_count ```
- ```min_node_count < node count ```  
For the sake of possible autoscaling, terraform will ignore changes made to the default node pool in consecutive runs. 

### Outputs and secrets 

The module outputs several kube-admin related secret strings, which are saved as key vault secrets in the client's subscription key vault: 
- ```kube_admin_client_key``` 
- ```kube_admin_client_cert```
- ```cluster_ca_certificate``` 
- ```kube_admin_password``` 
You can find some non-secret kube-admin related strings in the outputs.

### Ephemeral OS 

Several combinations of VM SKUs/Images and Disks are not supported by Microsoft. Please refer to the official documentation - https://docs.microsoft.com/en-us/azure/aks/cluster-configuration#ephemeral-os 

### Connecting to the Private AKS Cluster 

The API server endpoint has no public IP address. To manage the API server, you'll need to use a VM that has access to the AKS cluster's Azure Virtual Network (VNet). There are several options for establishing network connectivity to the private cluster. The easiest option is to create a VM in the same Azure Virtual Network (VNet) as the AKS cluster. Please refer to the official documentation - https://docs.microsoft.com/en-us/azure/aks/private-clusters#options-for-connecting-to-the-private-cluster 

## Common errors

Probably the most common error is the lack of permissions, while trying to assign the Private DNS Zone contributor role to the managed identity.   
This may happen if:   
1) you haven't requested the Owner rights on the ``` Platform-Identity-Prod-WestEurope ``` through PIM 
2) your rights have recently expired 
3) you have logged in via ``` az login ``` from your development environment BEFORE requesting the owner rights. You have to explicitly do ``` az logout ``` and then ``` az login ``` again for your rights to be reflected while using terraform. 

# Example Usage


```
terraform {
   backend "azurerm" {
     resource_group_name  = Your-stateResourceGroup
     storage_account_name = Your-stateStorageAcc
     container_name       = "terraformstate"
     key                  = "terraform.tfstate"
   }
}

provider "azurerm" {
  version = "~> 2.7"
  features {}
}

provider "azuread" {
  version = "~> 1.4.0"
}

provider "random" {
  version = "~> 2.3"
}

module "aks" {
  source                = "git::git@ssh.dev.azure.com:v3/RB-Group/RB.Cloud.Library/library.azure.aks"
  environment           = "DEV"
  application_code      = "AKS"
  app_tier              = "BackEnd"
  client_subscription_id = <your target subscription ID>
  sku_tier = "Free"
  auto_scaling = true
  os_disk_type = "Managed" 
}

```
 


