
#############################################################################################################################
# arm template deployment of logic app for resource health monitor

resource "azurerm_resource_group_template_deployment" "arm_logicapp_dmp_health_monitor" {
  name                = local.env.la_azurerm_template_deployment_name
  resource_group_name = local.env.ingest_resource_group_name
  deployment_mode     = "Incremental"
  template_content    = file("../scripts/la_dmp_resource_health_monitor_arm_template.json")

  parameters_content = jsonencode({
    dmp_adf_runway_id        = { value = azurerm_data_factory.runway_ingestion_adf[0].id }
    dmp_storage_datalake_id  = { value = local.env.runway_datalake_storage_account_id }
    dmp_eventhub_id          = { value = azurerm_eventhub_namespace.runway_ingestion_eventhub_namespace.id }
    dmp_functionapp_id       = { value = azurerm_function_app.runway_ingestion_fn_app[0].id }
    dmp_keyvault_id          = { value = azurerm_key_vault.runway_ingestion_key_vault.id }
    dmp_servicebus_id        = { value = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id }
    dmp_sql_db_metastore_id  = { value = local.env.runway_metastore_sql_database_id }
    dmp_sql_db_runway_id     = { value = azurerm_mssql_database.runway_ingestion_config_sql_database.id }
    dmp_sql_server_runway_id = { value = azurerm_mssql_server.runway_ingestion_sqlserver.id }
    dmp_databricks_id        = { value = local.env.runway_dbx_instance_url }

    dmp_adf_runway_name        = { value = azurerm_data_factory.runway_ingestion_adf[0].name }
    dmp_storage_datalake_name  = { value = local.env.runway_datalake_storage_account_name }
    dmp_eventhub_name          = { value = azurerm_eventhub_namespace.runway_ingestion_eventhub_namespace.name }
    dmp_eventhub_instance_name = { value = azurerm_eventhub.runway_ingestion_eventhub_namespace_eventhub.name }
    dmp_functionapp_name       = { value = azurerm_function_app.runway_ingestion_fn_app[0].name }
    dmp_keyvault_name          = { value = azurerm_key_vault.runway_ingestion_key_vault.name }
    dmp_servicebus_name        = { value = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name }
    dmp_sql_db_metastore_name  = { value = local.env.runway_metastore_sql_database_name }
    dmp_sql_db_runway_name     = { value = azurerm_mssql_server.runway_ingestion_sqlserver.name }
    dmp_databricks_name        = { value = local.env.runway_dbx_workspace_name }

    dmp_resource_group_name = { value = local.env.ingest_resource_group_name }
    dmp_subscription_id     = { value = local.env.la_app_subscription_id }
    dmp_location            = { value = local.env.location }
    dmp_logicapp_name       = { value = local.env.la_health_app_name }

    recurrence_interval_minutes = { value = "25" }
    retry_count                 = { value = "2" } #index start with 0
    retry_interval_minutes      = { value = "5" }

    dmp_keyvault_url = { value = "use kv name to generate kv url" }
    dmp_webhook_url  = { value = local.env.la_health_webhook_url }

    custom_message = { value = "custom message body for success state" }

    bug_bypass_unused_parm = { value = "bug-fix-${formatdate("YYMMDDhhmmss", timestamp())}" }

  })
}


# Grant read role to logic app on runway_ingestion_key_vault
resource "azurerm_role_assignment" "runway_ingestion_keyvault_logic_app_read_access" {
  scope                = azurerm_key_vault.runway_ingestion_key_vault.id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Allow logic app to read key from runway_ingestion_key_vault
resource "azurerm_key_vault_access_policy" "runway_ingest_logic_app_key_read_access_policy" {
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_key_vault.tenant_id
  object_id    = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on   = [azurerm_role_assignment.runway_ingestion_keyvault_logic_app_read_access]

  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List"
  ]
}

# Grant read role to logic app on runway_ingestion_adf
resource "azurerm_role_assignment" "runway_ingest_logic_app_adf_access" {
  scope                = azurerm_data_factory.runway_ingestion_adf[0].id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app from runway_ingestion_shared_adf
resource "azurerm_role_assignment" "runway_ingestion_shared_adf_logic_app_read_access" {
  scope                = azurerm_data_factory.runway_ingestion_shared_adf.id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app on runway_ingestion_servicebus_namespace
resource "azurerm_role_assignment" "runway_ingest_servicebus_namespace_read_logic_app" {
  scope                = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app from runway_ingestion_sqlserver
resource "azurerm_role_assignment" "runway_ingestion_sqlserver_logic_app_read_access" {
  scope                = azurerm_mssql_server.runway_ingestion_sqlserver.id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app from runway_ingestion_eventhub_namespace
resource "azurerm_role_assignment" "runway_ingestion_eventhun_logic_app_read_access" {
  scope                = azurerm_eventhub_namespace.runway_ingestion_eventhub_namespace.id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app from runway_ingestion_fn_app
resource "azurerm_role_assignment" "runway_ingestion_fnapp_logic_app_read_access" {
  scope                = azurerm_function_app.runway_ingestion_fn_app[0].id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app on log_analytics_workspace
resource "azurerm_role_assignment" "runway_log_analytics_logic_app_read_access" {
  scope                = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app on Storage_Account
resource "azurerm_role_assignment" "runway_storage_account_logic_app_read_access" {
  scope                = azurerm_storage_account.runway_ingestion_gcp_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to logic app from databricks
resource "azurerm_role_assignment" "build_databricks2_role_logic_app" {
  scope                = "/subscriptions/${local.env.runway_dbx_subscription_id}/resourceGroups/${local.env.runway_dbx_resource_group_name}/providers/Microsoft.Databricks/workspaces/${local.env.runway_dbx_workspace_name}"
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to sql metastore db in datalake rg
resource "azurerm_role_assignment" "runway_datalake_metastore2_sql_server_role_logic_app" {
  scope                = local.env.runway_metastore_sql_database_id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}

# Grant read role to storage account in datalake rg
resource "azurerm_role_assignment" "runway_datalake_storage_account_role_logic_app" {
  scope                = local.env.runway_datalake_storage_account_id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_health_monitor]
}


######################################################################################################################
# arm template deployment of logic app for long running pipeline monitor

resource "azurerm_resource_group_template_deployment" "arm_logicapp_dmp_long_running_pipelines" {
  name                = local.env.la_long_running_jobs_azurerm_template_name
  resource_group_name = local.env.ingest_resource_group_name
  deployment_mode     = "Incremental"
  template_content    = file("../scripts/la_dmp_long_running_pipeline_template.json")

  parameters_content = jsonencode({

    recurrence_interval_minutes = { value = "240" }
    past_interval_hour          = { value = "8" }
    dmp_location                = { value = local.env.location }
    dmp_logicapp_name           = { value = local.env.la_long_running_jobs_app_name }
    dmp_adf_url                 = { value = "https://management.azure.com/subscriptions/${local.env.la_app_subscription_id}/resourceGroups/rg-DMPEnterpriseDataIngestion-${local.env.environment_name}-001/providers/Microsoft.DataFactory/factories/${local.env.runway_adf_name[0]}/queryPipelineRuns?api-version=2018-06-01" }
    dmp_webhook_url             = { value = local.env.la_long_running_jobs_webhook_url }
    bug_bypass_unused_parm      = { value = "bug-fix-${formatdate("YYMMDDhhmmss", timestamp())}" }

  })
}

# Grant read role to logic app on runway_ingestion_adf
resource "azurerm_role_assignment" "runway_ingest_la_hung_adf_access" {
  scope                = azurerm_data_factory.runway_ingestion_adf[0].id
  role_definition_name = "Reader"
  principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_logicapp_dmp_long_running_pipelines.output_content).object_id.value
  depends_on           = [azurerm_resource_group_template_deployment.arm_logicapp_dmp_long_running_pipelines]
}

######################################################################################################################
