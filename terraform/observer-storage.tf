# Storage Account for Logs and Views of the DMP Ingestion Process
resource "azurerm_storage_account" "runway_observer_storage_account" {
  name                      = local.env.runway_observer_storage_account_name
  resource_group_name       = local.env.ingest_resource_group_name
  location                  = local.env.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  account_kind              = "StorageV2"
  is_hns_enabled            = "true"
  enable_https_traffic_only = "true"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["158.48.0.0/16"]
    virtual_network_subnet_ids = local.env.runway_observer_storage_account_subnet
    bypass                     = ["AzureServices"]
  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    lob              = local.env.tag_lob
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
  }
}

# Create landing container for logs and data
resource "azurerm_storage_container" "runway_observer_storage_account_landing_container" {
  name                  = "landing"
  storage_account_name  = azurerm_storage_account.runway_observer_storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.runway_observer_storage_account]
}


# Create public-projections container for data that is ready to be used.
resource "azurerm_storage_container" "runway_observer_storage_account_projections_container" {
  name                  = "public-projections"
  storage_account_name  = azurerm_storage_account.runway_observer_storage_account.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.runway_observer_storage_account]
}


# Grant the DMP developer group access to the landing storage container
resource "azurerm_role_assignment" "runway_developer_group_landing_container_data_contributor_role" {
  scope                = "${azurerm_storage_account.runway_observer_storage_account.id}/blobServices/default/containers/${azurerm_storage_container.runway_observer_storage_account_landing_container.name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.env.runway_developer_group_id
  depends_on           = [azurerm_storage_container.runway_observer_storage_account_landing_container]
}

# Grant the DMP developer group access to the projections storage container
resource "azurerm_role_assignment" "runway_developer_group_container_data_contributor_role" {
  scope                = "${azurerm_storage_account.runway_observer_storage_account.id}/blobServices/default/containers/${azurerm_storage_container.runway_observer_storage_account_projections_container.name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.env.runway_developer_group_id
  depends_on           = [azurerm_storage_container.runway_observer_storage_account_projections_container]
}
