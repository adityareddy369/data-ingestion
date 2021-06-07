resource "azurerm_eventgrid_topic" "runway_ingestion_eventgrid" {
  name                = local.env.runway_event_grid_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}
