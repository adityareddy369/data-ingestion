//Azure Data Factory
resource "azurerm_data_factory" "runway_ingestion_gcp_adf" {
  name                = local.env.runway_gcp_adf_name
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

resource "azurerm_role_assignment" "runway_ingestion_gcp_adf_contributor_role" {
  scope                = azurerm_data_factory.runway_ingestion_gcp_adf.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = local.env.runway_gcp_adf_group_id
}
