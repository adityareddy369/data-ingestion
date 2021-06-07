# create log analytics workspace
resource "azurerm_log_analytics_workspace" "runway_ingestion_log_analytics_workspace" {
  name                = local.env.runway_loganalytics_workspace_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}

//Store the workspace id in keyvault
resource "azurerm_key_vault_secret" "runway_ingestion_log_analytics_workspace_id_secret" {
  name         = "log-analytics-workspace-id"
  value        = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.workspace_id
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  depends_on   = [azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace]
}

//Store the workspace id in keyvault
resource "azurerm_key_vault_secret" "runway_ingestion_log_analytics_workspace_key_secret" {
  name         = "log-analytics-workspace-key"
  value        = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.primary_shared_key
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  depends_on   = [azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace]
}
