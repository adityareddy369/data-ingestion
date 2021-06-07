//creating eventhub namespace
resource "azurerm_eventhub_namespace" "runway_ingestion_eventhub_namespace" {
  name                = local.env.runway_event_hub_namespace_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  sku                 = "Standard"
  capacity            = 1

  network_rulesets {
    default_action = "Allow"
    # Need to revisit network rules for security posture
    # virtual_network_rule {
    #   subnet_id                                       = local.env.runway_event_hub_namespace_name-subnet-id
    #   ignore_missing_virtual_network_service_endpoint = true
    # }
    # ip_rule {
    #   ip_mask = "158.48.0.0/16"
    # }
  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}

//creating eventhub
resource "azurerm_eventhub" "runway_ingestion_eventhub_namespace_eventhub" {
  name                = local.env.runway_event_hub_logs_name
  namespace_name      = local.env.runway_event_hub_namespace_name
  resource_group_name = local.env.ingest_resource_group_name
  partition_count     = 2
  message_retention   = 1
  depends_on          = [azurerm_eventhub_namespace.runway_ingestion_eventhub_namespace]
}

//creating eventhub namespace authorization rule
resource "azurerm_eventhub_namespace_authorization_rule" "runway_ingestion_eventhub_namespace_authorization_rule" {
  name                = "dmp-fnapp-runway-${local.env.environment_name}-001"
  namespace_name      = local.env.runway_event_hub_namespace_name
  resource_group_name = local.env.ingest_resource_group_name
  depends_on          = [azurerm_eventhub_namespace.runway_ingestion_eventhub_namespace]

  listen = true
  send   = true
  manage = true
}

resource "azurerm_key_vault_secret" "runway_ingestion_eventhub_connection_string_secret" {
  name         = "${local.env.runway_event_hub_logs_name}-primary-connection-string"
  value        = azurerm_eventhub_namespace_authorization_rule.runway_ingestion_eventhub_namespace_authorization_rule.primary_connection_string
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "Event-Hub-Connection-String"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

# Configure Diagnostic Settings for  eventhub
resource "azurerm_monitor_diagnostic_setting" "runway_event_hub_diagnostics" {
  name                       = local.env.runway_event_hub_diagnostics_setting_name
  target_resource_id         = azurerm_eventhub_namespace.runway_ingestion_eventhub_namespace.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  log {
    category = "ArchiveLogs"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "OperationalLogs"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "AutoScaleLogs"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "KafkaCoordinatorLogs"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "KafkaUserErrorLogs"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "EventHubVNetConnectionEvent"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "CustomerManagedKeyUserLogs"

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

# Configure Diagnostic Settings for eventhub topic
resource "azurerm_monitor_diagnostic_setting" "runway_event_topic_diagnostics" {
  name                       = local.env.runway_event_topic_diagnostics_setting_name
  target_resource_id         = azurerm_eventgrid_topic.runway_ingestion_eventgrid.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  log {
    category = "DeliveryFailures"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "PublishFailures"

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
