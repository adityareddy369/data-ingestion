data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

//Azure key vault
resource "azurerm_key_vault" "runway_ingestion_key_vault" {
  name                     = local.env.runway_keyvault_name
  location                 = local.env.location
  resource_group_name      = local.env.ingest_resource_group_name
  sku_name                 = "standard"
  tenant_id                = data.azurerm_subscription.current.tenant_id
  purge_protection_enabled = true

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

}

//Allow development team's group object id to read/write/modify secrets from Key Vault
resource "azurerm_key_vault_access_policy" "runway_ingestion_developer_group_keyvault_policy" {
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_key_vault.tenant_id
  object_id    = local.env.runway_developer_group_id
  secret_permissions = [
    "get", "list", "set",
  ]
}

//Allow Service principal to read/write/modify secrets from Key Vault
resource "azurerm_key_vault_access_policy" "runway_ingestion_service_principal_keyvault_policy" {
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_key_vault.tenant_id
  object_id    = local.env.runway_deployer_service_principal_id

  key_permissions = [
    "get", "backup", "create", "delete", "import", "list", "recover", "restore", "update",
  ]

  secret_permissions = [
    "get", "backup", "delete", "list", "recover", "restore", "set",
  ]
}

//Allow Service principal to read/write/modify secrets from Key Vault
resource "azurerm_key_vault_access_policy" "runway_ingestion_provisioner_service_principal_keyvault_policy" {
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_key_vault.tenant_id
  object_id    = local.env.runway_provisioner_service_principal_id

  key_permissions = [
    "get", "backup", "create", "delete", "import", "list", "recover", "restore", "update",
  ]

  secret_permissions = [
    "get", "backup", "delete", "list", "recover", "restore", "set",
  ]
}

# Configure Diagnostic Settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "runway_ingestion_keyvault_diagnostics" {
  name                       = local.env.runway_key_vault_diagnostics_setting_name
  target_resource_id         = azurerm_key_vault.runway_ingestion_key_vault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  log {
    category = "AuditEvent"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Sending Keyvault Logs to Qradar eventhub
resource "azurerm_monitor_diagnostic_setting" "runway_ingestion_keyvault_log_qradar" {
  count                          = local.env.enableQRadar == 1 ? 1 : 0
  name                           = local.env.runway_ingestion_qradar_key_vault_log_name
  target_resource_id             = azurerm_key_vault.runway_ingestion_key_vault.id
  eventhub_name                  = local.env.runway_ingestion_qradar_eventhub_name
  eventhub_authorization_rule_id = local.env.runway_ingestion_qradar_eventhub_authorization_rule_id

  log {
    category = "AuditEvent"

    retention_policy {
      enabled = false
      days    = 0
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
