subscription_name = "DataManagementPlatformNonProd"
subscription_id   = "60b60000-6cbd-4c1b-94b3-2440bd6bbe00"
subscription      = "nonprod"
environment_name  = "dev"

# Git Integration for runway_observer_adf in terraform/observer-adf.tf
# Since only the Dev environment has ADF/Git Integration, we need to 
# configure that environment differently from the others. 
# 
# To accomplish that, we first define a variable with an empty list
# as the default value in the file terraform/variables.tf       <-- Look here
# 
# We then override that variable here and populate the settings for dev
runway_observer_adf_github_integration = [
  {
    account_name    = "krogertechnology"
    branch_name     = "dmp-adf-collaboration"
    git_url         = "https://github.com"
    repository_name = "dmp-runway-core"
    root_folder     = "azure/adf/runway_observer_adf"
  }
]

ccpa_ingestion_adf_github_integration = [
  {
    account_name    = "krogertechnology"
    branch_name     = "main"
    git_url         = "https://github.com"
    repository_name = "dmp-runway-core"
    root_folder     = "azure/adf/ccpa_ingestion_adf"
  }
]
