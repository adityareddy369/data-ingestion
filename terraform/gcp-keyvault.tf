data "azurerm_client_config" "currentkv" {}

//Azure key vault
resource "azurerm_key_vault" "runway_ingestion_gcp_keyvault" {
  name                     = local.env.runway_gcp_keyvault_name
  location                 = local.env.location
  resource_group_name      = local.env.ingest_resource_group_name
  sku_name                 = "standard"
  tenant_id                = data.azurerm_subscription.current.tenant_id
  depends_on               = [azurerm_data_factory.runway_ingestion_gcp_adf]
  purge_protection_enabled = true

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}


//Allow Data Factory to read secrets from Key Vault
resource "azurerm_key_vault_access_policy" "runway_ingestion_gcp_adf_keyvault_policy" {
  key_vault_id = azurerm_key_vault.runway_ingestion_gcp_keyvault.id
  tenant_id    = azurerm_key_vault.runway_ingestion_gcp_keyvault.tenant_id
  object_id    = azurerm_data_factory.runway_ingestion_gcp_adf.identity[0].principal_id
  key_permissions = [
    "get", "list",
  ]

  secret_permissions = [
    "get", "list",
  ]
}
