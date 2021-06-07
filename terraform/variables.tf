variable "subscription_name" {}
variable "subscription_id" {}
variable "subscription" {}
variable "environment_name" {}

# Git Integration for runway_observer_adf in terraform/observer-adf.tf
# Since only the Dev environment has ADF/Git Integration, we need to 
# configure that environment differently from the others. 
# 
# To accomplish that, we first define a shared variable with an empty list
# as the default value, and then override it for the dev environment by 
# configuring it in the file terraform/variables/dev.tfvars
variable "runway_observer_adf_github_integration" {
  type    = list(map(string))
  default = []
}

variable "ccpa_ingestion_adf_github_integration" {
  type    = list(map(string))
  default = []
}


// Generating password masking for sql  
 variable "sql_secret" {
   type                    = string
   sensitive               = true
   default                 = "secret"
}
