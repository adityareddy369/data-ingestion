//Generating random password for Azure SQL Server
resource "random_password" "runway_ingestion_sqlserver_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

// Azure Storage Account V2 to capture SQL Audit logs
resource "azurerm_storage_account" "runway_ingestion_sql_server_audit_log_storage_account" {
  name                     = local.env.runway_sql_server_audit_log_storage_account_name
  resource_group_name      = local.env.ingest_resource_group_name
  location                 = local.env.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "false"

  network_rules {
    default_action = "Deny"
    ip_rules       = ["158.48.0.0/16"]
    bypass         = ["AzureServices"]
  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}


//SQL Server
resource "azurerm_mssql_server" "runway_ingestion_sqlserver" {
  name                         = local.env.runway_sql_server_name
  resource_group_name          = local.env.ingest_resource_group_name
  location                     = local.env.location
  version                      = "12.0"
  administrator_login          = local.env.runway_sql_server_admin_sql_login_name
  administrator_login_password = random_password.runway_ingestion_sqlserver_password.result
  azuread_administrator {
    login_username = local.env.runway_sql_admin_login_name
    object_id      = local.env.runway_sql_active_directory_admin_id
  }
  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

}

// Adding sqlvnetrules on the SQL Server
resource "azurerm_mssql_virtual_network_rule" "runway_ingestion_sql_vnet_rule" {
  count               = length(local.env.runway_sql_subnet_ids)
  name                = "sql-vnet-rule-${count.index}"
  server_id           = azurerm_mssql_server.runway_ingestion_sqlserver.id
  subnet_id           = local.env.runway_sql_subnet_ids[count.index]
}

//Adding SQL Firewall rule on the SQL Server
resource "azurerm_mssql_firewall_rule" "runway_ingestion_sql_firewall_rule" {
  name                = "FirewallRule1"
  server_id           = azurerm_mssql_server.runway_ingestion_sqlserver.id
  start_ip_address    = "158.48.0.0"
  end_ip_address      = "158.48.255.255"
}

# The Azure feature Allow access to Azure services can be enabled by setting start_ip_address and end_ip_address to 0.0.0.0 https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_mssql_firewall_rule" "runway_ingestion_sql_firewall_rule_azure_services" {
  name                = "FirewallRuleAzureServices"
  server_id           = azurerm_mssql_server.runway_ingestion_sqlserver.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

// SQL Database
resource "azurerm_mssql_database" "runway_ingestion_config_sql_database" {
  name           = local.env.runway_config_sql_database_name
  server_id      = azurerm_mssql_server.runway_ingestion_sqlserver.id
  sku_name       = "P1"
  zone_redundant = true
  read_scale     = true

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

}


// Execute bash command to setup autotune setting at databse level
resource "null_resource" "execute_bash_command_sql_autotune" {

  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
    echo '${var.sql_secret}' \
    sqlcmd -S ${azurerm_mssql_server.runway_ingestion_sqlserver.name}.database.windows.net -d ${azurerm_mssql_database.runway_ingestion_config_sql_database.name} -U ${local.env.runway_sql_server_admin_sql_login_name} -P ${random_password.runway_ingestion_sqlserver_password.result} -l 100 -I -Q 'ALTER DATABASE current SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON, CREATE_INDEX = ON, DROP_INDEX = OFF)' -s ',' 
    EOT
    
  }
}

//store the random password in keyvault
resource "azurerm_key_vault_secret" "runway_ingestion_sqlserver_pass_secret" {
  name         = "AZURE-SQL-SERVER-PASSWORD"
  value        = random_password.runway_ingestion_sqlserver_password.result
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "SQL-Server-Password"
  depends_on   = [azurerm_mssql_server.runway_ingestion_sqlserver, azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

resource "azurerm_key_vault_secret" "runway_ingestion_sqlserver_user_secret" {
  name         = "AZURE-SQL-SERVER-USER"
  value        = local.env.runway_sql_server_admin_sql_login_name
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "SQL-Server-Admin-User"
  depends_on   = [azurerm_mssql_server.runway_ingestion_sqlserver, azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

#Secret creation for Config_db_LinkedServer
resource "azurerm_key_vault_secret" "runway_ingestion_configdb_secret" {
  name         = "DATA-SOURCE-RUNWAY-CONFIG-DB-CONNECTIONSTRING"
  value        = "Data Source=tcp:${azurerm_mssql_server.runway_ingestion_sqlserver.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.runway_ingestion_config_sql_database.name};User ID=${local.env.runway_sql_server_admin_sql_login_name};Password=${random_password.runway_ingestion_sqlserver_password.result};"
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "Config-db-connectionstring"
  depends_on   = [azurerm_mssql_server.runway_ingestion_sqlserver, azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}

# Configure Diagnostic Settings for runway config Azure SQL Database
resource "azurerm_monitor_diagnostic_setting" "runway_ingestion_sql_database_diagnostics" {
  name                       = local.env.runway_sql_database_diagnostics_setting_name
  target_resource_id         = azurerm_mssql_database.runway_ingestion_config_sql_database.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  log {
    category = "SQLInsights"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "AutomaticTuning"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "QueryStoreRuntimeStatistics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "QueryStoreWaitStatistics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "DevOpsOperationsAudit"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "SQLSecurityAuditEvents"
    enabled  = false
    retention_policy {
      enabled = false
      days    = 30
    }
  }

  log {
    category = "Errors"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "DatabaseWaitStatistics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "Timeouts"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "Blocks"

    retention_policy {
      enabled = true
      days    = 30
    }

  }

  log {
    category = "Deadlocks"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "Basic"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "InstanceAndAppAdvanced"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "WorkloadManagement"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Configure Diagnostic settings for Metastore Sql Database
resource "azurerm_monitor_diagnostic_setting" "runway_metastore_sql_database_diagnostics" {
  name                       = local.env.runway_metastore_sql_database_diagnostics_setting_name
  target_resource_id         = local.env.runway_metastore_sql_database_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id

  log {
    category = "SQLInsights"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "AutomaticTuning"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "QueryStoreRuntimeStatistics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }


  log {
    category = "QueryStoreWaitStatistics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "DevOpsOperationsAudit"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "SQLSecurityAuditEvents"
    enabled  = false
    retention_policy {
      enabled = false
      days    = 30
    }
  }

  log {
    category = "Errors"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "DatabaseWaitStatistics"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "Timeouts"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "Blocks"
    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "Deadlocks"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  metric {
    category = "Basic"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  metric {
    category = "InstanceAndAppAdvanced"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  metric {
    category = "WorkloadManagement"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
