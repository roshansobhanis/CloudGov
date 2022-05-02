- [Introduction](#introduction)
- [Module-specific Features](#module-specific-features)
  - [Prerequisites](#prerequisites)
  - [Build Guide](#technical-architecture)
    - [Contents Overview](#contents-overview)
  - [Common Errors](#service-configuration)
- [Example Usage](#example-usage)
---

# Introduction 

This module creates an Azure Container Registry instance. Azure Container Registry is a managed, private Docker registry service based on the open-source Docker Registry 2.0. It allows you to upload container images to the repositories. You can then use the containers in your environments. Use Azure container registries with your existing container development and deployment pipelines, or use Azure Container Registry Tasks to build container images in Azure. Build on demand, or fully automate builds with triggers such as source code commits and base image updates. 

# Module-specific features

## Prerequisites 

- Make sure you have read the official Microsoft documentation: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro.   
- The ACR instances created in our module have Content Trust feauture enabled: to cut the long story short, it won't enable users to use unsigned container images. This means that to be able to use the ACR, several additional RBAC roles must be configured and assigned. To be able to sign the container, a user (typically the subscription owner) must have an ACRImageSigner role assigned to them. The other important RBAC roles required to work with the ACR are ACRPull and ACRPush. 

## Build Guide

A template for the inputs can be found in the file terraform.tfvars.template, which comes as a part of this module. In case you are not using this module as a submodule inside any other terraform configuration, you can create a terraform.tfvars file in the same repository, copy the contents of the template and adjust the values to suit your needs. 

### Contents Overview

The contents of the module is very straighforward and easy to undestand. Only one basic resource - Azure Container Registry instance is created. No repositories inside the registry or images are created. This is a good starting point for each project, willing to work with the ACR.   
The ACR instance created inside the module has the following name structure (the name MUST be unique within Azure) "acrProjectnameEnvironmentRegion". 

## Common errors

- The registry name must be unique within Azure. So one common error may occur when you try create an ACR instance using already existent parameters.   
- Once you try to use an unsigned container, you will not be allowed to - due to the enabled Content Trust policy. 

# Example Usage

```
terraform {
   backend "azurerm" {
     resource_group_name  = < resource group name >
     storage_account_name = < storage account name >
     container_name       = "terraformstate"
     key                  = "terraform.tfstate"
   }
}

provider "azurerm" {
  version = "~> 2.7"
  features {}
}

module "acr" {
    environment           = "DEV"
    application_code      = "AAK"
    app_tier              = "BackEnd"
    source                = "git::git@ssh.dev.azure.com:v3/RB-Group/RB.Cloud.Library/library.azure.acr"
}

```
 


