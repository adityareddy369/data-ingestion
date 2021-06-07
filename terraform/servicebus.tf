// Azure Service Bus
resource "azurerm_servicebus_namespace" "runway_ingestion_servicebus_namespace" {
  name                = local.env.runway_servicebus_namespace_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  sku                 = "premium"
  capacity            = "1"

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}

resource "azurerm_servicebus_namespace_network_rule_set" "runway_ingestion_network_rule_set_Rule" {
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  resource_group_name = local.env.ingest_resource_group_name

  default_action = "Deny"

  dynamic "network_rules" {
    for_each = local.env.runway_servicebus_namespace_network_rules
    content {
      subnet_id                            = network_rules.value["subnet_id"]
      ignore_missing_vnet_service_endpoint = network_rules.value["ignore_missing_vnet_service_endpoint"]
    }
  }

  ip_rules = local.env.runway_servicebus_namespace_ip_rules
}

// Runway Internal Service Bus Topic
resource "azurerm_servicebus_topic" "runway_ingestion_servicebus_topic" {
  name                      = local.env.runway_servicebus_topic_name
  resource_group_name       = local.env.ingest_resource_group_name
  namespace_name            = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  enable_partitioning       = false
  enable_batched_operations = true
}

// Integration Event Service Bus Topic
resource "azurerm_servicebus_topic" "runway_integration_event_servicebus_topic" {
  name                      = local.env.runway_integration_event_servicebus_topic_name
  resource_group_name       = local.env.ingest_resource_group_name
  namespace_name            = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  enable_partitioning       = false
  enable_batched_operations = true
}

resource "azurerm_servicebus_topic_authorization_rule" "runway_ingestion_servicebus_topic_authorization_rule" {
  name                = "${local.env.runway_servicebus_topic_name}-sasPolicy"
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  resource_group_name = local.env.ingest_resource_group_name
  listen              = true
  send                = true
  manage              = true
}


resource "azurerm_servicebus_topic_authorization_rule" "runway_integration_event_servicebus_topic_authorization_rule" {
  name                = "${local.env.runway_integration_event_servicebus_topic_name}-sasPolicy"
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_integration_event_servicebus_topic.name
  resource_group_name = local.env.ingest_resource_group_name
  listen              = true
  send                = true
  manage              = true
}

// ServiceBus pipeline_runner Subscription 
resource "azurerm_servicebus_subscription" "runway_ingestion_servicebus_subscription_pipeline_runner" {
  name                = local.env.runway_servicebus_subscription_pipeline_runner
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  auto_delete_on_idle = local.env.runway_servicebus_subscription_auto_delete_on_idle
}

// ServiceBus pipeline_cleaner Subscription 
resource "azurerm_servicebus_subscription" "runway_ingestion_servicebus_subscription_pipeline_cleaner" {
  name                = local.env.runway_servicebus_subscription_pipeline_cleaner
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  auto_delete_on_idle = local.env.runway_servicebus_subscription_auto_delete_on_idle
}

// ServiceBus execution_status Subscription 
resource "azurerm_servicebus_subscription" "runway_ingestion_servicebus_subscription_execution_status" {
  name                = local.env.runway_servicebus_subscription_execution_status
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  auto_delete_on_idle = local.env.runway_servicebus_subscription_auto_delete_on_idle
}

// ServiceBus message_logger Subscription 
resource "azurerm_servicebus_subscription" "runway_ingestion_servicebus_subscription_message_logger" {
  name                = local.env.runway_servicebus_subscription_message_logger
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  auto_delete_on_idle = local.env.runway_servicebus_subscription_auto_delete_on_idle
}

// ServiceBus workflow_invoker Subscription 
resource "azurerm_servicebus_subscription" "runway_ingestion_servicebus_subscription_workflow_invoker" {
  name                = local.env.runway_servicebus_subscription_workflow_invoker
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  auto_delete_on_idle = local.env.runway_servicebus_subscription_auto_delete_on_idle
}

// ServiceBus forward_integration_events Subscription 
resource "azurerm_servicebus_subscription" "runway_ingestion_servicebus_subscription_forward_integration_events" {
  name                = local.env.runway_servicebus_subscription_forward_integration_events
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  forward_to          = azurerm_servicebus_topic.runway_integration_event_servicebus_topic.name
}

// ServiceBus runway_servicebus_subscription_process_monitor
resource "azurerm_servicebus_subscription" "runway_ingestion_servicebus_subscription_process_monitor" {
  name                = local.env.runway_servicebus_subscription_process_monitor
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_ingestion_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  auto_delete_on_idle = local.env.runway_servicebus_subscription_auto_delete_on_idle
}

// ServiceBus integration-events_servicebus_subscription_process_monitor
resource "azurerm_servicebus_subscription" "runway_integration_event_servicebus_subscription_process_monitor" {
  name                = local.env.runway_integration_event_servicebus_subscription_process_monitor
  resource_group_name = local.env.ingest_resource_group_name
  namespace_name      = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name
  topic_name          = azurerm_servicebus_topic.runway_integration_event_servicebus_topic.name
  max_delivery_count  = local.env.runway_servicebus_subscription_max_delivery_count
  default_message_ttl = local.env.runway_servicebus_subscription_default_message_ttl
  lock_duration       = local.env.runway_servicebus_subscription_lock_duration
  auto_delete_on_idle = local.env.runway_servicebus_subscription_auto_delete_on_idle
}

# Secrets must be removed from TF state and cycled.
resource "azurerm_key_vault_secret" "runway_ingestion_servicebus_topic_connection_string_secret" {
  name         = "${local.env.runway_servicebus_topic_name}-primary-connection-string"
  value        = azurerm_servicebus_topic_authorization_rule.runway_ingestion_servicebus_topic_authorization_rule.primary_connection_string
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "Service-bus-Connection-String"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

resource "azurerm_key_vault_secret" "runway_ingestion_servicebus_topic_connection_string_secret_no_entity_path" {
  name         = "${local.env.runway_servicebus_topic_name}-primary-connection-string-no-entity-path"
  value        = "Endpoint=sb://${azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name}.servicebus.windows.net/;SharedAccessKeyName=${azurerm_servicebus_topic_authorization_rule.runway_ingestion_servicebus_topic_authorization_rule.name};SharedAccessKey=${azurerm_servicebus_topic_authorization_rule.runway_ingestion_servicebus_topic_authorization_rule.primary_key}"
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "Service-bus-Connection-String"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

resource "azurerm_key_vault_secret" "runway_integration_event_servicebus_topic_connection_string_secret_no_entity_path" {
  name         = "${local.env.runway_integration_event_servicebus_topic_name}-primary-connection-string-no-entity-path"
  value        = "Endpoint=sb://${azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.name}.servicebus.windows.net/;SharedAccessKeyName=${azurerm_servicebus_topic_authorization_rule.runway_integration_event_servicebus_topic_authorization_rule.name};SharedAccessKey=${azurerm_servicebus_topic_authorization_rule.runway_integration_event_servicebus_topic_authorization_rule.primary_key}"
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "Service-bus-Connection-String"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

# Configure Diagnostic Settings for Azure Service Bus
resource "azurerm_monitor_diagnostic_setting" "runway_ingestion_service_bus_diagnostics" {
  name                       = local.env.runway_servicebus_diagnostics_setting_name
  target_resource_id         = azurerm_servicebus_namespace.runway_ingestion_servicebus_namespace.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  log {
    category = "OperationalLogs"

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
