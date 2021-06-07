#Dmp Compound dashboard for monitoring log analytics
resource "azurerm_dashboard" "runway_ingestion_compound_log_analytics_dashboard" {
  name                = local.env.runway_compound_analytics_dashboard_name
  resource_group_name = local.env.ingest_resource_group_name
  location            = local.env.location
  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
  dashboard_properties = templatefile("../scripts/compound-log-analytics-monitoring-dashboard-properties.json",
    {
      tenant_id                            = local.env.tenant_id
      subscription_id                      = var.subscription_id
      ingest_resource_group_name           = local.env.ingest_resource_group_name
      runway_onprem_adf_ir_name            = local.env.runway_onprem_adf_ir_name
      datalake_resource_group_name         = local.env.datalake_resource_group_name
      runway_metastore_sql_server_name     = local.env.runway_metastore_sql_server_name
      runway_sql_server_name               = azurerm_mssql_server.runway_ingestion_sqlserver.name
      dmp_runway_data_factory_name         = azurerm_data_factory.runway_ingestion_adf[0].name
      dmp_runway_servicebus_name           = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
      dmp_runway_functionapp_name          = azurerm_function_app.runway_ingestion_fn_app[0].name
      dmp_runway_application_insights_name = azurerm_application_insights.runway_ingestion_application_insights.name
      dmp_runway_config_sql_db_name        = azurerm_mssql_database.runway_ingestion_config_sql_database.name
      dmp_runway_key_vault_name            = azurerm_key_vault.runway_ingestion_key_vault.name
      dmp_log_analytics_workspace_name     = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.name
  })
}
