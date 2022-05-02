# required variables 

variable "application_code" {
   type        = string
   description = "The name of the application that is being deployed. Ex. GLM | VLL "
}

variable "environment" {
   type        = string
   description = "The environment type that is being deployed.  Allowed Values: Prod | Dev | QA | Test"
}

variable "app_tier" {
   type        = string
   description = "The application tier. Allowed values: FrontEnd | BackEnd | AppTier"
}

variable "client_subscription_id" {
   type        = string
   description = "The target client subscription to create the AKS cluster"
}

# optional variables 
variable "sku_tier" {
   type        = string
   default     = "Free"
   description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid. The default value if free."

   validation {
     condition     = contains(["Free", "Paid"], var.sku_tier)
     error_message = "The SKU Tier that should be one of the following: Free or Paid."
   }
}

variable "kube_dashboard" {
   type        = bool
   default     = true
   description = "Is the Kubernetes Dashboard enabled?"
}

variable "auto_scaling" {
   type        = bool
   default     = false
   description = "Should the Kubernetes Auto Scaler be enabled for this Node Pool? Default is false"
}

variable "os_disk_type" {
   type        = string
   default     = "Managed"
   description = " The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. "

   validation {
     condition     = contains(["Ephemeral", "Managed"], var.os_disk_type)
     error_message = "Use one of the following: Ephemeral, Managed."
   }

}

variable "node_count" {
   type        = number 
   default     = 2
   description = "The initial number of nodes which should exist in this Node Pool. Must be between 1 and 1000"
}

variable "max_count" {
   type        = number 
   default     = 3
   description = "Takes place only if ENABLE_AUTO_SCALING = TRUE; The maximum number of nodes which should exist in this Node Pool. Defaults to 5. Can't be less than node_count."
}

variable "min_count" {
   type        = number 
   default     = 1
   description = "Takes place only if ENABLE_AUTO_SCALING = TRUE; The minimum number of nodes which should exist in this Node Pool. Default is 1. Can't be greater than node_count."
}

variable "vm_size" {
   type        = string
   default     = "Standard_D2_v2"
   description = "The size of the Virtual Machine"
}


