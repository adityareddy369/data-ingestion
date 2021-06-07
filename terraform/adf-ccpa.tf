# CCPA Azure Data Factory

# CCPA Azure Data Factory resource
resource "azurerm_data_factory" "ccpa_ingestion_adf" {
  name                = local.env.ccpa_adf_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  identity {
    type = "SystemAssigned"
  }

  # Configure Github integration for ADF
  # 
  # Since only the Dev environment has ADF/Git Integration, we need to 
  # configure that environment differently from the others. 
  # 
  # To accomplish that, we first define a variable with an empty list
  # as the default value in the file terraform/variables.tf       <-- Look here
  # 
  # We then override that variable for the dev environment by 
  # configuring values in the file terraform/variables/dev.tfvars <-- Look here
  # 
  # The list variable now contains one or zero items depending on environment.
  # 
  # Finally, since Terraform doesn't support using object variables to
  # populate blocks - we use a "dynamic" statement which iterates 
  # through the list and populates the github_configuration block.
  dynamic "github_configuration" {
    for_each = var.ccpa_ingestion_adf_github_integration

    content {
      account_name    = github_configuration.value["account_name"]
      branch_name     = github_configuration.value["branch_name"]
      git_url         = github_configuration.value["git_url"]
      repository_name = github_configuration.value["repository_name"]
      root_folder     = github_configuration.value["root_folder"]
    }
  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}

# CCPA ADF identity role assignment
resource "azurerm_role_assignment" "ccpa_ingestion_shared_adf_contributor_role" {
  scope                = azurerm_data_factory.runway_ingestion_shared_adf.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = azurerm_data_factory.ccpa_ingestion_adf.identity.0.principal_id

  depends_on = [azurerm_data_factory.ccpa_ingestion_adf, azurerm_data_factory.runway_ingestion_shared_adf]
}

# Allow Data Factory to read secrets from Key Vault
resource "azurerm_key_vault_access_policy" "ccpa_ingestion_adf_kv_policy" {
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_key_vault.tenant_id
  object_id    = azurerm_data_factory.ccpa_ingestion_adf.identity.0.principal_id

  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
  ]

  depends_on = [azurerm_key_vault.runway_ingestion_key_vault, azurerm_data_factory.ccpa_ingestion_adf]
}
