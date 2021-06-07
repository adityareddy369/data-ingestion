// Azure Blob Storage Account Creation
resource "azurerm_storage_account" "runway_ingestion_gcp_storage_account" {
  name                     = local.env.runway_gcp_storage_name
  resource_group_name      = local.env.ingest_resource_group_name
  location                 = local.env.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }

  network_rules {
    default_action = "Deny"
    ip_rules       = ["158.48.0.0/16"]
    bypass         = ["AzureServices"]
  }
}

//Granting Storage Blob Data Reader access
resource "azurerm_role_assignment" "runway_ingestion_gcp_storage_blob_data_reader_role" {
  scope                = azurerm_storage_account.runway_ingestion_gcp_storage_account.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_data_factory.runway_ingestion_adf[0].identity.0.principal_id
}

//Granting Storage Blob Data Contributor access 
resource "azurerm_role_assignment" "runway_ingestion_gcp_storage_blob_data_contributor_role" {
  scope                = azurerm_storage_account.runway_ingestion_gcp_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.runway_ingestion_gcp_adf.identity[0].principal_id
}
