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
