////Azure Application Insights
resource "azurerm_application_insights" "runway_ingestion_application_insights" {
  name                = local.env.runway_app_insights_name
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name
  application_type    = local.env.runway_app_insights_application_type
  retention_in_days   = 90

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}
