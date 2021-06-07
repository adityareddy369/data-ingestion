# Dmp Compound dashboard for monitoring Metrics
resource "azurerm_dashboard" "runway_ingestion_compound_metric_dashboard" {
  name                = local.env.runway_compound_metric_dashboard_name
  resource_group_name = local.env.ingest_resource_group_name
  location            = local.env.location
  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
  dashboard_properties = templatefile("../scripts/compound-metric-monitoring-dashboard-properties.json",
    {
      tenant_id                                   = local.env.tenant_id
      subscription_id                             = var.subscription_id
      ingest_resource_group_name                  = local.env.ingest_resource_group_name
      runway_onprem_adf_ir_name                   = local.env.runway_onprem_adf_ir_name
      datalake_resource_group_name                = local.env.datalake_resource_group_name
      runway_metastore_sql_server_name            = local.env.runway_metastore_sql_server_name
      runway_metastore_sql_database_name          = local.env.runway_metastore_sql_database_name
      location                                    = local.env.location
      runway_metastore_sql_database_id            = local.env.runway_metastore_sql_database_id
      runway_datalake_storage_account_name        = local.env.runway_datalake_storage_account_name
      runway_datalake_storage_account_id          = local.env.runway_datalake_storage_account_id
      dmp_runway_data_factory_name                = azurerm_data_factory.runway_ingestion_adf[0].name
      dmp_runway_data_factory_resource_id         = azurerm_data_factory.runway_ingestion_adf[0].id
      dmp_runway_shared_data_factory_resource_id  = azurerm_data_factory.runway_ingestion_shared_adf.id
      dmp_runway_data_factory_self_hosted_ir_name = azurerm_data_factory_integration_runtime_self_hosted.runway_ingestion_adf_ir_self_hosted.name
      dmp_runway_servicebus_name                  = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
      dmp_runway_servicebus_id                    = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id
      dmp_runway_servicebus_topic_name            = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
      dmp_runway_functionapp_name                 = azurerm_function_app.runway_ingestion_fn_app[0].name
      dmp_runway_functionapp_id                   = azurerm_function_app.runway_ingestion_fn_app[0].id
      dmp_runway_application_insights_name        = azurerm_application_insights.runway_ingestion_application_insights.name
      dmp_runway_application_insights_id          = azurerm_application_insights.runway_ingestion_application_insights.id
      dmp_runway_config_sql_db_name               = azurerm_mssql_database.runway_ingestion_config_sql_database.name
      dmp_runway_config_sql_db_id                 = azurerm_mssql_database.runway_ingestion_config_sql_database.id
      dmp_runway_key_vault_name                   = azurerm_key_vault.runway_ingestion_key_vault.name
      dmp_runway_key_vault_id                     = azurerm_key_vault.runway_ingestion_key_vault.id
      subscription_name                           = var.subscription_name
      dmp_log_analytics_workspace_name            = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.name
      runway_sql_server_name                      = azurerm_mssql_server.runway_ingestion_sqlserver.name
  })
}
