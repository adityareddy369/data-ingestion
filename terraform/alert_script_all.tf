# create alert action group mail only ( receive only mail for P4)
resource "azurerm_monitor_action_group" "runway_ingestion_alert_action_group" {
  name                = local.env.runway_alert_action_group_name
  resource_group_name = local.env.ingest_resource_group_name
  short_name          = "dmpalert"

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

  email_receiver {
    name                    = local.env.runway_alert_action_group_email_name
    email_address           = local.env.runway_alert_support_email
    use_common_alert_schema = true
  }
}

# create alert ation group with webhook integration major severity (receive call,ticket,mail for P2 and P1)
resource "azurerm_monitor_action_group" "runway_ingestion_alert_ticket_action_group_major" {
  name                = local.env.runway_alert_action_group_name_ticket_major
  resource_group_name = local.env.ingest_resource_group_name
  short_name          = "dmptktmajor"

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

  webhook_receiver {
    name                    = local.env.runway_alert_action_group_webhook_major_name
    service_uri             = local.env.runway_alert_ticket_major_url
    use_common_alert_schema = true
  }

  email_receiver {
    name                    = local.env.runway_alert_action_group_ticket_email_name
    email_address           = local.env.runway_alert_support_email
    use_common_alert_schema = true
  }
}


# create alert ation group with webhook integration minor severity (Only mail and ticket for P3)
resource "azurerm_monitor_action_group" "runway_ingestion_alert_ticket_action_group_minor" {
  name                = local.env.runway_alert_action_group_name_ticket_minor
  resource_group_name = local.env.ingest_resource_group_name
  short_name          = "dmptktminor"

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

  webhook_receiver {
    name                    = local.env.runway_alert_action_group_webhook_minor_name
    service_uri             = local.env.runway_alert_ticket_minor_url
    use_common_alert_schema = true
  }

  email_receiver {
    name                    = local.env.runway_alert_action_group_ticket_email_name
    email_address           = local.env.runway_alert_support_email
    use_common_alert_schema = true
  }
}

# create Custom alert ation group with webhook integration major severity (receive call,ticket,mail for P2 and P1)
resource "azurerm_monitor_action_group" "ops_alert_ticket_action_group_major" {
  name                = local.env.ops_alert_action_group_name_ticket_major_name
  resource_group_name = local.env.ingest_resource_group_name
  short_name          = "dmpcsttktmjr"

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

  webhook_receiver {
    name                    = local.env.ops_alert_action_group_webhook_major_name
    service_uri             = local.env.ops_alert_ticket_major_url
    use_common_alert_schema = false
  }

  email_receiver {
    name                    = local.env.runway_alert_action_group_ticket_email_name
    email_address           = local.env.runway_alert_support_email
    use_common_alert_schema = true
  }
}

# configure function app http4xx alert only
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_funapp_http4xx" {
  name                = local.env.runway_alert_functionapp_http_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_function_app.runway_ingestion_fn_app[0].id]
  description         = "Action will be triggered when Http4xx error is greater than 20"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute (aggrigation granularity)

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http4xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 20
    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure function app ResponseTime alert with ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_funapp_ResponseTime" {
  name                = local.env.runway_alert_functionapp_responsetime_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_function_app.runway_ingestion_fn_app[0].id]
  description         = "Action will be triggered when ResponseTime is greater than 100 second"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HttpResponseTime"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100
    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure function app Http5xx (server error) alert with ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_funapp_Http5xx" {
  name                = local.env.runway_alert_functionapp_http5x_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_function_app.runway_ingestion_fn_app[0].id]
  description         = "Action will be triggered when total count of Http5xx server error is greater than 5"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5
    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure service bus UserErrors  alert with ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_servicebus_alert_UserErrors" {
  name                = local.env.runway_alert_servicebus_usererror_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id]
  description         = "Action will be triggered when total count of user error is greater than 10"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "UserErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = ["*"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure service bus ServerErrors  alert with ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_servicebus_alert_ServerErrors" {
  name                = local.env.runway_alert_servicebus_servererror_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id]
  description         = "Action will be triggered when total count of server error is greater than 10"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ServerErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = ["*"]
    }
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure service bus DeadletteredMessages  alert with ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_servicebus_alert_DeadletteredMessages" {
  name                = local.env.runway_alert_servicebus_deadmessage_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id]
  description         = "Action will be triggered when average count of DeadletteredMessages is greater than 10"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "DeadletteredMessages"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 10
    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure service bus CPUXNS  alert 
resource "azurerm_monitor_metric_alert" "runway_ingestion_servicebus_alert_CPUXNS" {
  name                = local.env.runway_alert_servicebus_cpuxns_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id]
  description         = "Action will be triggered when CPUXNS percentage is greater than 90"
  frequency           = "PT5M" # default 5 minute
  severity            = 3
  window_size         = "PT5M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "CPUXNS" #cpu
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql alerts for storage percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_storage_percent" {
  name                = local.env.runway_alert_sql_storagepercent_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when average dataspace used percent is greater than 80"
  frequency           = "PT5M" # default 5 minute
  severity            = 3
  window_size         = "PT5M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql alerts for cpu percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_cpu_percent" {
  name                = local.env.runway_alert_sql_cpupercent_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when average cpu percentage is greater than 60"
  frequency           = "PT30M" # default 5 minute
  severity            = 4
  window_size         = "PT30M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 60
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql alerts for cpu percent more than 80 %
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_cpu_percent_hi" {
  name                = local.env.runway_alert_sql_cpupercent_hi_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when average cpu percentage is greater than 80"
  frequency           = "PT5M" # default 5 minute
  severity            = 3
  window_size         = "PT5M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql alerts for deadlock
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_deadlock" {
  name                = local.env.runway_alert_sql_deadlock_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when total deadlock count is greater than or equal to 10"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "deadlock"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql alerts for physical_data_read_percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_physical_data_read" {
  name                = local.env.runway_alert_sql_dataread_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when average data_io_percent is greater than 90"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "physical_data_read_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql alerts for session percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_sessions_percent" {
  name                = local.env.runway_alert_sql_session_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when average sessions_percent is greater than 80"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "sessions_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql alerts for worker percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_workers_percent" {
  name                = local.env.runway_alert_sql_worker_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when average workers percent is greater than 80"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "workers_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql alerts for  connection failed
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_connection_failed" {
  name                = local.env.runway_alert_sql_failconnection_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when total count of failed connection is greater than 10"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "connection_failed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql alerts for firewall block
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_blocked_by_firewall" {
  name                = local.env.runway_alert_sql_firewall_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when total count of blocked by firewall is greater than 15"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "blocked_by_firewall"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 15
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# sql deltalake (metadata) alert configurations 
# configure sql datalake alerts for storage percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_storage_percent" {
  name                = local.env.runway_alert_sql_datalake_storagepercent_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when average dataspace used percent is greater than 80"
  frequency           = "PT5M" # default 5 minute
  severity            = 3
  window_size         = "PT5M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql datalake alerts for cpu percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_cpu_percent" {
  name                = local.env.runway_alert_sql_datalake_cpupercent_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when average cpu percentage is greater than 60"
  frequency           = "PT30M" # default 5 minute
  severity            = 4
  window_size         = "PT30M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 60
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql datalake alerts for cpu percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_cpu_percent_hi" {
  name                = local.env.runway_alert_sql_datalake_cpupercent_hi_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when average cpu percentage is greater than 80"
  frequency           = "PT5M" # default 5 minute
  severity            = 3
  window_size         = "PT5M" # default 5 minute
  dynamic_criteria {
    metric_namespace         = "Microsoft.Sql/servers/databases"
    metric_name              = "cpu_percent"
    aggregation              = "Average"
    operator                 = "GreaterThan"
    alert_sensitivity        = "Medium"
    evaluation_failure_count = 4
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql datalake alerts for deadlock
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_deadlock" {
  name                = local.env.runway_alert_sql_datalake_deadlock_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when total deadlock count is greater than or equal to 10"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "deadlock"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql datalake alerts for data read percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_physical_data_read" {
  name                = local.env.runway_alert_sql_datalake_dataread_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when average data_io_percent is greater than 90"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "physical_data_read_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql datalake alerts for session percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_sessions_percent" {
  name                = local.env.runway_alert_sql_datalake_session_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when average sessions_percent is greater than 80"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "sessions_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql datalake alerts for workers percent
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_workers_percent" {
  name                = local.env.runway_alert_sql_datalake_worker_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when average workers_percent is greater than 80"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "workers_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure sql datalake alerts for failed connections
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_connection_failed" {
  name                = local.env.runway_alert_sql_datalake_failconnection_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when total count of failed connection is greater than 10"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "connection_failed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure sql datalake alerts for firewall block
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_sql_datalake_blocked_by_firewall" {
  name                = local.env.runway_alert_sql_datalake_firewall_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when total count of blocked by firewall is greater than 15"
  frequency           = "PT15M" # default 5 minute
  severity            = 3
  window_size         = "PT15M" # default 5 minute
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "blocked_by_firewall"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 15
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}


# configure adls alert for availability
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_adls_availability" {
  name                = local.env.runway_alert_adls_datalake_availability_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_datalake_storage_account_id]
  description         = "Action will be triggered when average availability is less than 25 percent"
  frequency           = "PT30M"
  severity            = 3
  window_size         = "PT30M"
  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 25
  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }

}

# configure adf alert pipline failed runs with ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_adf_pipelinefailedRuns" {
  name                = local.env.runway_alert_adf_piplinefail_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_data_factory.runway_ingestion_adf[0].id]
  description         = "Action will be triggered when total count of PipelineFailedRuns is Greater Than Or Equal to 2"
  frequency           = "PT5M"
  severity            = 3
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = "PipelineFailedRuns"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 2

    dimension {
      name     = "FailureType"
      operator = "Exclude"
      values   = ["SystemError"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}


# configure adf alert pipline failed runs with out ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_adf_pipelinefailedRuns_no_ticket" {
  name                = local.env.runway_alert_adf_piplinefail_name_no_ticket
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_data_factory.runway_ingestion_adf[0].id]
  description         = "Action will be triggered when total count of PipelineFailedRuns is Greater Than Or Equal to 1"
  frequency           = "PT5M"
  severity            = 4
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = "PipelineFailedRuns"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 1

    dimension {
      name     = "FailureType"
      operator = "Exclude"
      values   = ["SystemError"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}


# configure adf trigger failed alert with ticket
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_adf_triggerfailedruns" {
  name                = local.env.runway_alert_adf_triggerfail_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_data_factory.runway_ingestion_adf[0].id]
  description         = "Action will be triggered when total count of TriggerFailedRuns is Greater Than Or Equal to 1"
  frequency           = "PT5M"
  severity            = 3
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = "TriggerFailedRuns"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure alert Create/Update Azure SQL Database
resource "azurerm_monitor_activity_log_alert" "runway_ingestion_alert_sql_create_update" {
  name                = local.env.runway_alert_audit_sql_create_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when sql database is created or updated"
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.SQL/servers/databases/write"
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure alert Delete Azure SQL Database
resource "azurerm_monitor_activity_log_alert" "runway_ingestion_alert_sql_delete" {
  name                = local.env.runway_alert_audit_sql_delete_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when sql database is deleted"
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.SQL/servers/databases/delete"
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure Rename Azure SQL Database
resource "azurerm_monitor_activity_log_alert" "runway_ingestion_alert_sql_rename" {
  name                = local.env.runway_alert_audit_sql_rename_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_mssql_database.runway_ingestion_config_sql_database.id]
  description         = "Action will be triggered when sql database is renamed"
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.SQL/servers/databases/move/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}


# configure Create/Update Azure SQL datalake
resource "azurerm_monitor_activity_log_alert" "runway_ingestion_alert_sql_datalake_create_update" {
  name                = local.env.runway_alert_audit_sql_create_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when sql database is created or updated"
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.SQL/servers/databases/write"
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure Delete Azure SQL datalake
resource "azurerm_monitor_activity_log_alert" "runway_ingestion_alert_sql_datalake_delete" {
  name                = local.env.runway_alert_audit_sql_datalake_delete_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when sql database is deleted"
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.SQL/servers/databases/delete"
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure Rename Azure SQL datalake
resource "azurerm_monitor_activity_log_alert" "runway_ingestion_alert_sql_datalake_rename" {
  name                = local.env.runway_alert_audit_sql_datalake_rename_name
  resource_group_name = local.env.datalake_resource_group_name
  scopes              = [local.env.runway_metastore_sql_database_id]
  description         = "Action will be triggered when sql database is renamed"
  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.SQL/servers/databases/move/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure Key Vault Availability 
resource "azurerm_monitor_metric_alert" "runway_ingestion_keyvault_Availability" {
  name                = local.env.runway_alert_keyvault_available_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_key_vault.runway_ingestion_key_vault.id]
  description         = "Action will be triggered when average overall availability is less than 100 percent"
  frequency           = "PT5M" # default 5 minute
  severity            = 3
  window_size         = "PT5M" # default 5 minute (aggregation granularity)

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100

  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

# configure Key Vault Latency 
resource "azurerm_monitor_metric_alert" "runway_ingestion_keyvault_Latency" {
  name                = local.env.runway_alert_keyvault_latency_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_key_vault.runway_ingestion_key_vault.id]
  description         = "Action will be triggered when average overall service api latency is greater than 500 milliseconds"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute (aggregation granularity)

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 500

  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}

# configure Key Vault Total Error Codes 
resource "azurerm_monitor_metric_alert" "runway_ingestion_keyvault_Total_Error_Codes" {
  name                = local.env.runway_alert_keyvault_error_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_key_vault.runway_ingestion_key_vault.id]
  description         = "Action will be triggered when total ServiceApiResult is greater than or equal to 1"
  frequency           = "PT15M" # default 5 minute
  severity            = 4
  window_size         = "PT15M" # default 5 minute (aggregation granularity)

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "ServiceApiResult"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 1
    dimension {
      name     = "StatusCode"
      operator = "Include"
      values   = ["400"]
    }

  }
  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_action_group.id
  }
}


# Integration runtime availability node count check (check in shared adf )
resource "azurerm_monitor_metric_alert" "runway_ingestion_alert_shr_adf_IR_node" {
  name                = local.env.runway_alert_shr_adf_ir_availability_name
  resource_group_name = local.env.ingest_resource_group_name
  scopes              = [azurerm_data_factory.runway_ingestion_shared_adf.id]
  description         = "Action will be triggered when total number of available node count is less than 2"
  frequency           = "PT5M"
  severity            = 3
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = "IntegrationRuntimeAvailableNodeNumber"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 2
  }

  action {
    action_group_id = azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert" "runway_ingestion_alert_funapp_exceptions" {
  name                = local.env.runway_alert_funapp_exceptions_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  data_source_id      = azurerm_application_insights.runway_ingestion_application_insights.id
  description         = "FunctionApp Exceptions summarized by operation_Name, problemID"
  enabled             = true
  query               = <<-QUERY
                        exceptions
                        |summarize count() by operation_Name, problemId
                        |sort by count_ desc
                        QUERY
  severity            = 3
  frequency           = 5
  time_window         = 5
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
  action {
    action_group = [azurerm_monitor_action_group.runway_ingestion_alert_ticket_action_group_minor.id]
    custom_webhook_payload = jsonencode({
      "healthchecks" : [
        {
          "body" : {
            "properties" : {
              "summary" : "   ALERT NAME - #alertrulename, RESULT COUNT - #searchresultcount, QUERY TIME - #searchintervalstarttimeutc   "
            }
          },
          "service" : "   DMP_ALERT_BUILD_FUNAPPEXCEPTIONS   ",
          "status" : "   FUNCTION APP EXCEPTIONS  "
        }
      ],
      "host" : "dmp-service-health-check",
      "index" : "2b575356-7000-11eb-9439"
    })

  }
}

// Adding a template for Resource Health Alerts
resource "azurerm_resource_group_template_deployment" "dmp_ops_resource_health" {
  name                = "DMP_resourcehealth"
  resource_group_name = local.env.ingest_resource_group_name
  deployment_mode     = "Incremental"
  template_content    = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "activityLogAlertName": {
      "type": "String",
      "defaultValue" : "dmp_alert_${var.environment_name}_resource_health",
      "metadata": {
        "description": "Unique name (within the Resource Group) for the Activity log alert."
      }
    },
    "actionGroupName": {
      "type": "String",
      "defaultValue" : "${azurerm_monitor_action_group.runway_ingestion_alert_action_group.name}",
      "metadata": {
        "description": "Unique name (within the Resource Group) for the Action group."
      }
    },
    "actionGroupResourceId": {
      "type": "String",
      "defaultValue" : "[resourceId('Microsoft.Insights/actionGroups',parameters('actionGroupName'))]",
      "metadata": {
        "description": "Resource Id for the Action group."
      }
    }
  },
   "resources": [
        {
            "type": "Microsoft.Insights/activityLogAlerts",
            "apiVersion": "2017-04-01",
            "name": "[parameters('activityLogAlertName')]",
            "location": "Global",
            "properties": {
                "enabled": true,
                "scopes": [
                    "/subscriptions/${var.subscription_id}/resourceGroups/rg-DMPEnterpriseDataIngestion-${var.environment_name}-001",
                    "/subscriptions/${var.subscription_id}/resourceGroups/rg-DMPEnterpriseDataLake-${var.environment_name}-001"
                ],
                "description": "Current and historical health status of resources",
                "condition": {
                    "allOf": [
                        {
                            "field": "category",
                            "equals": "ResourceHealth",
                            "containsAny": null
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Available",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Unavailable",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Degraded",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Available",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Unavailable",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Degraded",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.cause",
                                    "equals": "PlatformInitiated",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "status",
                                    "equals": "Active",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "Resolved",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "In Progress",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "Updated",
                                    "containsAny": null
                                }
                            ]
                        }
                    ]
                },
                "actions": {
                    "actionGroups": [
                        {
                            "actionGroupId": "[parameters('actionGroupResourceId')]"
                        }
                    ]
                }
            }
        }
         
    ]
}
TEMPLATE

}

// Adding a template for Service Health Alerts

resource "azurerm_resource_group_template_deployment" "dmp_ops_template" {
  name                = "DMP_servicehealth"
  resource_group_name = local.env.ingest_resource_group_name
  deployment_mode     = "Incremental"
  template_content    = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "activityLogAlertName": {
      "type": "String",
      "defaultValue" : "dmp_alert_${var.environment_name}_service_health",
      "metadata": {
        "description": "Unique name (within the Resource Group) for the Activity log alert."
      }
    },
    "activityLogAlertName_compound": {
      "type": "String",
      "defaultValue" : "dmp_alert_${var.environment_name}_service_health_compound",
      "metadata": {
        "description": "Unique name (within the Resource Group) for the Activity log alert."
      }
    },
    "actionGroupName": {
      "type": "String",
      "defaultValue" : "${azurerm_monitor_action_group.runway_ingestion_alert_action_group.name}",
      "metadata": {
        "description": "Unique name (within the Resource Group) for the Action group."
      }
    },
    "ServiceHealthRegions": {
      "type": "Array",
      "defaultValue" : ["East US 2", "Central US"]
    },
    "ServiceHealthServices": {
      "type": "Array",
      "defaultValue" : ["Data Factory V2", 
                        "Key Vault", 
                        "Log Analytics",
                        "Logic Apps",
                        "Service Bus",
                        "SQL Database",
                        "Storage",
                        "Virtual Machines",
                        "Virtual Network",
                        "Functions"
                    ]
    },
    "actionGroupResourceId": {
      "type": "String",
      "defaultValue" : "[resourceId('Microsoft.Insights/actionGroups',parameters('actionGroupName'))]",
      "metadata": {
        "description": "Resource Id for the Action group."
      }
    }
  },
   "resources": [
        {
            "type": "Microsoft.Insights/activityLogAlerts",
            "apiVersion": "2017-04-01",
            "name": "[parameters('activityLogAlertName')]",
            "location": "Global",
            "properties": {
                "enabled": true,
                "scopes": [
                    "${data.azurerm_subscription.current.id}"
                ],
                "condition": {
                    "allOf": [
                        {
                            "field": "category",
                            "equals": "ServiceHealth",
                            "containsAny": null
                        },
                        {
                            "field": "properties.incidentType",
                            "equals": "Incident",
                            "containsAny": null
                        },
                        {
                            "field": "properties.impactedServices[*].ImpactedRegions[*].RegionName",
                            "equals": null,
                            "containsAny": "[parameters('ServiceHealthRegions')]"
                        },
                        {
                            "field": "properties.impactedServices[*].ServiceName",
                            "equals": null,
                            "containsAny": "[parameters('ServiceHealthServices')]"
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Available",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Unavailable",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Degraded",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Available",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Unavailable",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Degraded",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.cause",
                                    "equals": "PlatformInitiated",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "status",
                                    "equals": "Active",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "Resolved",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "In Progress",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "Updated",
                                    "containsAny": null
                                }
                            ]
                        }
                    ]
                },
                "actions": {
                    "actionGroups": [
                        {
                            "actionGroupId": "[parameters('actionGroupResourceId')]"
                        }
                    ]
                }
            }
        },
         {
            "type": "Microsoft.Insights/activityLogAlerts",
            "apiVersion": "2017-04-01",
            "name": "[parameters('activityLogAlertName_compound')]",
            "location": "Global",
            "properties": {
                "enabled": true,
                "scopes": [
                    "${data.azurerm_subscription.current.id}"
                ],
                "condition": {
                    "allOf": [
                        {
                            "field": "category",
                            "equals": "ServiceHealth",
                            "containsAny": null
                        },
                        {
                            "field": "properties.incidentType",
                            "equals": "Maintenance",
                            "containsAny": null
                        },
                        {
                            "field": "properties.incidentType",
                            "equals": "Informational",
                            "containsAny": null
                        },
                        {
                            "field": "properties.incidentType",
                            "equals": "Security",
                            "containsAny": null
                        },
                        {
                            "field": "properties.impactedServices[*].ImpactedRegions[*].RegionName",
                            "equals": null,
                            "containsAny": "[parameters('ServiceHealthRegions')]"
                        },
                        {
                            "field": "properties.impactedServices[*].ServiceName",
                            "equals": null,
                            "containsAny": "[parameters('ServiceHealthServices')]"
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Available",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Unavailable",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.currentHealthStatus",
                                    "equals": "Degraded",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Available",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Unavailable",
                                    "containsAny": null
                                },
                                {
                                    "field": "properties.previousHealthStatus",
                                    "equals": "Degraded",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "properties.cause",
                                    "equals": "PlatformInitiated",
                                    "containsAny": null
                                }
                            ]
                        },
                        {
                            "anyOf": [
                                {
                                    "field": "status",
                                    "equals": "Active",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "Resolved",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "In Progress",
                                    "containsAny": null
                                },
                                {
                                    "field": "status",
                                    "equals": "Updated",
                                    "containsAny": null
                                }
                            ]
                        }
                    ]
                },
                "actions": {
                    "actionGroups": [
                        {
                            "actionGroupId": "[parameters('actionGroupResourceId')]"
                        }
                    ]
                }
            }
        }
    ]
}
TEMPLATE

}

// Log Analytics based scheduled alert to query failed pipelines

resource "azurerm_monitor_scheduled_query_rules_alert" "scheduled_alert_log_analytics" {
  name                = local.env.scheduled_alert_la_failed_pipeline
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  data_source_id      = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id
  description         = "Log Analytics Query based alert to track failed pipelines for particular datasets"
  enabled             = true
  query               = <<-QUERY
        ADFActivityRun
		| join kind=inner(ADFPipelineRun | where Status == 'Cancelled' or Status == 'Failed')
		on $left.PipelineRunId == $right.RunId
		|where Level == 'Error'
		and OperationName contains "databricks"
		and Input contains "ocado"
		|extend payload = parse_json(tostring(parse_json(tostring(parse_json(Input).baseParameters.job_payload)).processor))
		|extend output_payload = parse_json(Output)
		|sort by PipelineRunId desc,Start desc
		|extend rank = row_number(1,prev(PipelineRunId) != PipelineRunId or prev(ActivityName) != ActivityName)
		|filter rank == 1
		|project Start,PipelineRunId,PipelineName,Status,
		output_payload.runPageUrl,
		payload.source_folder_path		
    QUERY
  severity            = 2
  frequency           = 15
  time_window         = 15
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
  action {
    action_group = [azurerm_monitor_action_group.ops_alert_ticket_action_group_major.id]
    custom_webhook_payload = jsonencode({
  "description": "OCADO FAILED PIPELINE:\n JOBS FAILED - #searchresultcount \n QUERY TIME - #searchintervalstarttimeutc   ",
  "host": "DMP_OCADO_FAILED_PIPELINE_ALERT",
  "index": "2b575356-7000-11eb-9439-#searchintervalstarttimeutc"
})
  }
}
