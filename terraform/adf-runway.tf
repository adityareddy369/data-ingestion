# Runway Azure Data Factory
# The Azure DataFactory, shared Azure DataFactory, and shared Integration Runtime 
# consumed by both ADF instances was created via the model found here:
# https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/examples/data-factory/shared-self-hosted/main.tf

resource "azurerm_data_factory" "runway_ingestion_adf" {
  count               = length(local.env.runway_adf_name)
  name                = local.env.runway_adf_name[count.index]
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
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

}

# Runway Shared Azure Data Factory
resource "azurerm_data_factory" "runway_ingestion_shared_adf" {
  name                = local.env.runway_shared_adf_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
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

}

# The Runway ADF identity needs access to the Runway Shared ADF to add the shared
# Integration Runtime within the Runway Shared ADF to the Runway ADF
resource "azurerm_role_assignment" "runway_ingestion_shared_adf_contributor_role" {
  scope                = azurerm_data_factory.runway_ingestion_shared_adf.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = lookup(azurerm_data_factory.runway_ingestion_adf[0].identity[0], "principal_id")
}

# Allow Data Factory to read secrets from Key Vault
resource "azurerm_key_vault_access_policy" "runway_ingestion_adf_kv_policy" {
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_key_vault.tenant_id
  object_id    = azurerm_data_factory.runway_ingestion_adf[0].identity.0.principal_id

  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
  ]
}

# This Integration Runtime reference places the shared Integration runtime on the Runway ADF via the poorly named
# rbac_authorization property.  The depends_on ensures that the VMs have connected to the SHR IR before connecting
# this reference.
resource "azurerm_data_factory_integration_runtime_self_hosted" "runway_ingestion_adf_ir_self_hosted" {
  name                = azurerm_data_factory_integration_runtime_self_hosted.runway_ingestion_shared_adf_ir_self_hosted.name
  data_factory_name   = azurerm_data_factory.runway_ingestion_adf[0].name
  resource_group_name = local.env.ingest_resource_group_name

  rbac_authorization {
    resource_id = azurerm_data_factory_integration_runtime_self_hosted.runway_ingestion_shared_adf_ir_self_hosted.id
  }

  depends_on = [azurerm_role_assignment.runway_ingestion_shared_adf_contributor_role, azurerm_virtual_machine_extension.runway_ingestion_adf_vm_ext_ir_install[0], azurerm_virtual_machine_extension.runway_ingestion_adf_vm_ext_ir_install[1]]
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "runway_ingestion_shared_adf_ir_self_hosted" {
  name                = local.env.runway_shared_adf_ir_name
  data_factory_name   = azurerm_data_factory.runway_ingestion_shared_adf.name
  resource_group_name = local.env.ingest_resource_group_name
}

# Creating default linked service for key vault
resource "azurerm_data_factory_linked_service_key_vault" "runway_ingestion_adf_ls_kv" {
  name                = "lsADFKeyVault"
  resource_group_name = local.env.ingest_resource_group_name
  data_factory_name   = azurerm_data_factory.runway_ingestion_adf[0].name
  key_vault_id        = azurerm_key_vault.runway_ingestion_key_vault.id
}

#added datafactory contributor acces to databricks
resource "azurerm_role_assignment" "runway_ingestion_databricks_role_assignment" {
  scope                = "/subscriptions/${local.env.runway_dbx_subscription_id}/resourceGroups/${local.env.runway_dbx_resource_group_name}/providers/Microsoft.Databricks/workspaces/${local.env.runway_dbx_workspace_name}"
  role_definition_name = "contributor"
  principal_id         = azurerm_data_factory.runway_ingestion_adf[0].identity.0.principal_id
}

# Creating default linked service for databricks
# A Terraform resource does not exist for dbx linked service, so this must be a script
resource "null_resource" "runway_ingestion_script_create_or_update_databricks_ls" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "pwsh -File ../scripts/Create-DbxLinkedService.ps1 -Environment ${local.env.environment_name} -AdfResourceGroupName ${local.env.ingest_resource_group_name} -DataFactoryName ${azurerm_data_factory.runway_ingestion_adf[0].name} -IntegrationRuntimeName ${azurerm_data_factory_integration_runtime_self_hosted.runway_ingestion_adf_ir_self_hosted.name} -DbxResourceGroupName ${local.env.runway_dbx_resource_group_name} -DbxInsanceUrl ${local.env.runway_dbx_instance_url} -DbxWorkspaceName ${local.env.runway_dbx_workspace_name} -DbxInstancePoolName ${local.env.runway_dbx_instance_pool_name} -DbxSecretScopeName ${local.env.runway_dbx_secret_scope_name} -DbxLinkedServiceId ${local.env.etl_dbx_raw_writer_id}"
  }

  depends_on = [azurerm_role_assignment.runway_ingestion_databricks_role_assignment, azurerm_data_factory_integration_runtime_self_hosted.runway_ingestion_adf_ir_self_hosted]
}

#the value of attribute "log_analytics_destination_type" is always empty string regardless what is defined in the terraform code. 
#Which leads every terraform plan showing CHANGE every time it is run.
#https://github.com/terraform-providers/terraform-provider-azurerm/issues/8131   
#Configuring diagnostic settings of Data Factory to Event Hub
resource "azurerm_monitor_diagnostic_setting" "runway_ingestion_adf_diagnostic_setting" {
  name                           = "events-to-eventhub-log"
  target_resource_id             = azurerm_data_factory.runway_ingestion_adf[0].id
  eventhub_name                  = azurerm_eventhub.runway_ingestion_eventhub_namespace_eventhub.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.runway_ingestion_eventhub_namespace_authorization_rule.id
  log {
    category = "ActivityRuns"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "PipelineRuns"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "TriggerRuns"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISIntegrationRuntimeLogs"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageEventMessageContext"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageEventMessages"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageExecutableStatistics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageExecutionComponentPhases"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageExecutionDataStatistics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SandboxPipelineRuns"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SandboxActivityRuns"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
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

# Configure Diagnostic settings for Azure Data Factory
resource "azurerm_monitor_diagnostic_setting" "runway_ingestion_data_factory_diagnostics" {
  name                           = local.env.runway_data_factory_diagnostics_setting_name
  target_resource_id             = azurerm_data_factory.runway_ingestion_adf[0].id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.runway_ingestion_log_analytics_workspace.id
  log_analytics_destination_type = "Dedicated"

  log {
    category = "ActivityRuns"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "PipelineRuns"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "TriggerRuns"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
  log {
    category = "SSISIntegrationRuntimeLogs"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageEventMessageContext"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageEventMessages"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageExecutableStatistics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {

    category = "SSISPackageExecutionComponentPhases"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SSISPackageExecutionDataStatistics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SandboxPipelineRuns"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SandboxActivityRuns"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
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
