// Azure App Service Plan
resource "azurerm_app_service_plan" "runway_ingestion_app_service_plan" {
  name                = local.env.runway_app_service_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  kind                = "Linux"
  reserved            = true
  sku {
    tier     = "PremiumV2"
    size     = local.env.runway_app_service_plan_size
    capacity = 2
  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}

// Azure Storage Account V2
resource "azurerm_storage_account" "runway_ingestion_fn_app_storage_account" {
  name                     = local.env.runway_ingestion_fn_app_storage_account_name
  resource_group_name      = local.env.ingest_resource_group_name
  location                 = local.env.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "false"

  network_rules {
    default_action             = "Allow"
    ip_rules                   = local.env.runway_ingestion_fn_app_storage_account_ip_rules
    virtual_network_subnet_ids = local.env.runway_ingestion_fn_app_storage_account_subnet_ids
    bypass                     = ["AzureServices"]

  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}

//Azure Function App
resource "azurerm_function_app" "runway_ingestion_fn_app" {
  count                     = length(local.env.runway_ingestion_fn_app_name)
  name                      = local.env.runway_ingestion_fn_app_name[count.index]
  location                  = local.env.location
  resource_group_name       = local.env.ingest_resource_group_name
  app_service_plan_id       = azurerm_app_service_plan.runway_ingestion_app_service_plan.id
  storage_connection_string = azurerm_storage_account.runway_ingestion_fn_app_storage_account.primary_connection_string
  os_type                   = "linux"
  depends_on                = [azurerm_storage_account.runway_ingestion_fn_app_storage_account, azurerm_app_service_plan.runway_ingestion_app_service_plan]
  daily_memory_time_quota   = "0"
  version                   = "~3"
  enable_builtin_logging    = false
  https_only                = true

  site_config {
    linux_fx_version = "PYTHON|3.7"
    always_on        = true
    ftps_state       = "Disabled"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                 = azurerm_application_insights.runway_ingestion_application_insights.instrumentation_key
    "BUILD_FLAGS"                                    = "UseExpressBuild"
    "CONFIGDB_CONNECTIONSTRING_SECRETNAME"           = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-connectionstring"
    "CONFIGDB_PASSWORD_SECRETNAME"                   = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-password"
    "CONFIGDB_USERNAME_SECRETNAME"                   = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-username"
    "CONFIGDB_USE_MSI"                               = "false"
    "DATALAKE_CLIENT_ID_SECRETNAME"                  = "svc-5839-runway-platform-support-clientid"
    "DATALAKE_CLIENT_SECRET_SECRETNAME"              = "svc-5839-runway-platform-support-password"
    "DEFAULT_DATA_FACTORY_NAME"                      = "dmp-adf-runway-${local.env.environment_name}-001"
    "DEFAULT_RESOURCE_GROUP_NAME"                    = "rg-DMPEnterpriseDataIngestion-${local.env.environment_name}-001"
    "DEFAULT_SUBSCRIPTION_ID"                        = local.env.subscription_id
    "ENABLE_ORYX_BUILD"                              = "false"
    "EVENTHUB_CONNECTION_STRING"                     = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.runway_ingestion_key_vault.name};SecretName=${azurerm_key_vault_secret.runway_ingestion_eventhub_connection_string_secret.name};SecretVersion=${azurerm_key_vault_secret.runway_ingestion_eventhub_connection_string_secret.version})"
    "EVENTHUB_NAME"                                  = azurerm_eventhub.runway_ingestion_eventhub_namespace_eventhub.name
    "FUNCTIONS_WORKER_RUNTIME"                       = "python"
    "FUNCTIONS_WORKER_PROCESS_COUNT"                 = 6
    "FUNCTION_APP_EDIT_MODE"                         = "readwrite"
    "KEYVAULT_URL"                                   = "https://dmp-kv-runway-${local.env.environment_name}-001.vault.azure.net/"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"                 = "0"
    "SCM_NO_REPOSITORY"                              = "1"
    "SERVICEBUS_CONNECTION_STRING"                   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.runway_ingestion_key_vault.name};SecretName=${azurerm_key_vault_secret.runway_ingestion_servicebus_topic_connection_string_secret_no_entity_path.name};SecretVersion=${azurerm_key_vault_secret.runway_ingestion_servicebus_topic_connection_string_secret_no_entity_path.version})"
    "SERVICEBUS_TOPIC_NAME"                          = "dmp-sbt-runway-${local.env.environment_name}-001"
    "SERVICEBUS_INTEGRATION_EVENT_CONNECTION_STRING" = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.runway_ingestion_key_vault.name};SecretName=${azurerm_key_vault_secret.runway_integration_event_servicebus_topic_connection_string_secret_no_entity_path.name};SecretVersion=${azurerm_key_vault_secret.runway_integration_event_servicebus_topic_connection_string_secret_no_entity_path.version})"
    "SERVICEBUS_INTEGRATION_EVENT_TOPIC_NAME"        = "dmp-sbt-integration-events-${var.environment_name}-001"
    "TENANT_ID"                                      = data.azurerm_subscription.current.tenant_id
    "UNRESTRICTED_READER_GROUP"                      = local.env.runway_adls_unrestricted_reader
    "UNRESTRICTED_WRITER_GROUP"                      = local.env.runway_adls_unrestricted_writer
    "WEBSITE_RUN_FROM_PACKAGE"                       = "1"
    "WEBSITE_HTTPLOGGING_RETENTION_DAYS"             = null
    "XDG_CACHE_HOME"                                 = "/tmp/.cache"
    "OPERATIONS_INFRA_URL"                           = local.env.operations_infra_url
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_HTTPLOGGING_RETENTION_DAYS"]
    ]
  }

}

//Assign Storage Blob Data Contributor role on Storage Account to Function App
resource "azurerm_role_assignment" "runway_ingestion_storage_account_role" {
  count                = length(local.env.runway_ingestion_fn_app_name)
  scope                = azurerm_storage_account.runway_ingestion_fn_app_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = lookup(azurerm_function_app.runway_ingestion_fn_app[count.index].identity[0], "principal_id")
}

//Assign Data Factory Contributor role on dmp-adf-runway-dev/test/stage/prod-001 Data Factory to dmp-fnapp-runway-dev/test/stage/prod-001 Function App
resource "azurerm_role_assignment" "runway_ingestion_adf_account_role_Contributor" {
  scope                = azurerm_data_factory.runway_ingestion_adf[0].id
  role_definition_name = "Data Factory Contributor"
  principal_id         = lookup(azurerm_function_app.runway_ingestion_fn_app[0].identity[0], "principal_id")
}

resource "azurerm_app_service_virtual_network_swift_connection" "runway_ingestion_adf_function_app_subnet_conn" {
  app_service_id = azurerm_function_app.runway_ingestion_fn_app[0].id
  subnet_id      = local.env.runway_ingestion_fn_app_swift_subnet
}

//Allow Function App to read secrets from Key Vault
resource "azurerm_key_vault_access_policy" "runway_ingestion_function_app_keyvault_policy" {
  count        = length(local.env.runway_ingestion_fn_app_name)
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_key_vault.tenant_id
  object_id    = azurerm_function_app.runway_ingestion_fn_app[count.index].identity.0.principal_id

  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
  ]
}

resource "random_password" "runway_ingestion_function_app_sql_server_password" {
  length           = 64
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "runway_ingestion_function_app_connectionstring_secret" {
  name         = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-connectionstring"
  value        = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=dmp-sql-runway-${local.env.environment_name}-001.database.windows.net;PORT=1433;DATABASE=dmp-sqldb-runway-configuration"
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-connectionstring"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

//Creating secret for Azure function app in Azure key vault
resource "azurerm_key_vault_secret" "runway_ingestion_function_app_username_secret" {
  name         = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-username"
  value        = "dmp-fnapp-runway-${local.env.environment_name}-001-user"
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-username"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

//Creating secret for Azure function app in Azure key vault
resource "azurerm_key_vault_secret" "runway_ingestion_function_app_password_secret" {
  name         = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-password"
  value        = random_password.runway_ingestion_function_app_sql_server_password.result
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "dmp-fnapp-runway-${local.env.environment_name}-001-sql-configdb-password"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

# Configure Diagnostic Settings for Function App 
resource "azurerm_monitor_diagnostic_setting" "runway_ingestion_functionapp_diagnostics" {
  name                       = local.env.runway_fn_app_diagnostics_setting_name
  target_resource_id         = azurerm_function_app.runway_ingestion_fn_app[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  log {
    category = "FunctionAppLogs"

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

# Configure Diagnostic Settings for appservice plan functionapp
resource "azurerm_monitor_diagnostic_setting" "runway_fnap_appservice_diagnostics" {
  name                       = local.env.runway_fnapp_serviceplan_diagnostics_setting_name
  target_resource_id         = azurerm_app_service_plan.runway_ingestion_app_service_plan.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

}
