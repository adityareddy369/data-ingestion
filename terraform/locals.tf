# Common and Environment specific locals

locals {
  subscription = {
    nonprod = {
      # backend_storage_account_id = data.azurerm_storage_account.terraform_backend.id
      subscription                         = "nonprod"
      subscription_id                      = "60b60000-6cbd-4c1b-94b3-2440bd6bbe00"
      runway_deployer_service_principal_id = "3958837e-cce0-45eb-ac7a-aae095b5817e" # dmp-nonprod-deployer

      # Subnets
      runway_subnet_adfintegrationruntime = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpnonprod-eastus2-vnet/subnets/adfintegrationruntime"
      runway_build_functions_subnet       = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpnonprod-eastus2-vnet/subnets/dmp-runway-build-nonprod-eastus2"
      runway_dev_functions_subnet         = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpnonprod-eastus2-vnet/subnets/dmp-runway-dev-nonprod-eastus2"
      runway_test_functions_subnet        = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpnonprod-eastus2-vnet/subnets/dmp-runway-test-nonprod-eastus2"
      runway_build_dbx_subnet             = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/krcdp_databricks_dmp_dev-eastus2-vnet/subnets/krcdp_databricks_dmp_dev-public"
      runway_dev_dbx_subnet               = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/krcdp_databricks_dmp_dev-eastus2-vnet/subnets/krcdp_databricks_dmp_dev-public"
      runway_test_dbx_subnet              = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/krcdp_databricks_dmp_dev-eastus2-vnet/subnets/krcdp_databricks_dmp_dev-public"
      dq_dev_dbx_subnet                   = "/subscriptions/42e7e66b-7a91-4243-a172-dd4e81db8a20/resourceGroups/rg-dmp-dq-dev-dbx/providers/Microsoft.Network/virtualNetworks/dmp-dq-dev-dbx-eastus2-vnet/subnets/dmp-dq-dev-dbx-public-subnet"
      dq_test_dbx_subnet                  = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/rg-dmp-dq-dbx-np/providers/Microsoft.Network/virtualNetworks/dmp-dq-test-dbx-eastus2-vnet/subnets/dmp-dq-test-dbx-eastus2-public-subnet"
      tsacentralus_azdocentralus_id       = "/subscriptions/45c9a658-02d1-4c1b-a2ec-0a38383c3259/resourceGroups/rg-networking-centralus/providers/Microsoft.network/virtualNetworks/vnet-tsa-centralus-spoke/subnets/azdo-centralus"

      # GCP Backload Group
      runway_gcp_adf_group_id = "2348efbc-011e-4026-be37-8921e8af9f67" # Only Prod and NonProd groups exist

    }
    prod = {
      # backend_storage_account_id = data.azurerm_storage_account.terraform_backend.id
      subscription                         = "prod"
      subscription_id                      = "d4ed766d-813e-4037-b448-2d1dd7ef81f6"
      runway_deployer_service_principal_id = "dd4e3fc0-98cd-466c-97ab-01bcbd206313" # dmp-prod-deployer

      # Subnets
      runway_subnet_adfintegrationruntime = "/subscriptions/d4ed766d-813e-4037-b448-2d1dd7ef81f6/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpprod-eastus2-vnet/subnets/adfintegrationruntime-prod-eastus2"
      runway_stage_functions_subnet       = "/subscriptions/d4ed766d-813e-4037-b448-2d1dd7ef81f6/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpprod-eastus2-vnet/subnets/dmp-runway-stage-prod-eastus2"
      runway_prod_functions_subnet        = "/subscriptions/d4ed766d-813e-4037-b448-2d1dd7ef81f6/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpprod-eastus2-vnet/subnets/dmp-runway-prod-prod-eastus2"
      runway_stage_dbx_subnet             = "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpetl-stage-dbxws-eastus2-vnet/subnets/dmpetl-stage-dbxws-public"
      runway_prod_dbx_subnet              = "/subscriptions/d4ed766d-813e-4037-b448-2d1dd7ef81f6/resourceGroups/networking-eastus2/providers/Microsoft.Network/virtualNetworks/dmpetl-prod-dbxws-eastus2-vnet/subnets/dmpetl-prod-dbxws-public"
      dq_prod_dbx_subnet                  = "/subscriptions/d4ed766d-813e-4037-b448-2d1dd7ef81f6/resourceGroups/rg-dmp-dq-dbx-prod/providers/Microsoft.Network/virtualNetworks/dmp-dq-prod-dbx-eastus2-vnet/subnets/dmp-dq-prod-dbx-eastus2-public-subnet"
      tsacentralus_azdocentralus_id       = "/subscriptions/45c9a658-02d1-4c1b-a2ec-0a38383c3259/resourceGroups/rg-networking-centralus/providers/Microsoft.network/virtualNetworks/vnet-tsa-centralus-spoke/subnets/azdo-centralus"

      # GCP Backload Group
      runway_gcp_adf_group_id = "4908d401-6990-4119-a225-119e9fb8ce40" # Only Prod and NonProd groups exist
    }
  }
  environment = {
    common = {
      tenant_id                  = data.azurerm_subscription.current.tenant_id
      subscription               = var.subscription
      runway_dbx_subscription_id = var.subscription_id
      subscription_name          = data.azurerm_subscription.current.display_name
      repo_name                  = "dmp-enterprise-data-ingestion"
      environment_name           = var.environment_name
      location                   = "EAST US 2"
      ingest_resource_group_name = "rg-DMPEnterpriseDataIngestion-${var.environment_name}-001"

      # Replace these with references to their respective resources once the repos are merged
      datalake_resource_group_name         = "rg-DMPEnterpriseDataLake-${var.environment_name}-001"
      runway_datalake_storage_account_name = "dmpdatalake${var.environment_name}"
      runway_datalake_storage_account_id   = "/subscriptions/${var.subscription_id}/resourceGroups/rg-DMPEnterpriseDataLake-${var.environment_name}-001/providers/Microsoft.Storage/storageAccounts/dmpdatalake${var.environment_name}"
      runway_metastore_sql_database_id     = "/subscriptions/${var.subscription_id}/resourceGroups/rg-DMPEnterpriseDataLake-${var.environment_name}-001/providers/Microsoft.Sql/servers/dmp-sql-metastore-${var.environment_name}-001/databases/DMP_Hive_Metastore"
      runway_metastore_sql_server_name     = "dmp-sql-metastore-${var.environment_name}-001"
      runway_metastore_sql_database_name   = "DMP_HIVE_METASTORE"

      # Tags
      tag_application_name = "DMP"
      tag_cost_center      = "9999"
      tag_owner            = "anderson.muse@kroger.com"
      tag_spm_id           = "5839"
      tag_lob              = "TSA TECH"

      # Alert Scopes
      runway_alert_support_email    = "INF-DMP-SUPPORT@kroger.com"
      runway_alert_ticket_major_url = "http://35.190.24.217/v1/azure-dbx"
      runway_alert_ticket_minor_url = "http://35.190.24.217/v1/azure-dbx"
      #Custom Alert URL
      ops_alert_ticket_major_url    = "http://35.190.24.217/v1/azure-dbx"

      # Application Insights Group
      runway_app_insights_name             = "dmp-appi-runway-${var.environment_name}-001"
      runway_app_insights_application_type = "web"

      #Dashboard Group
      runway_compound_metric_dashboard_name    = "DMP-${upper(var.environment_name)}-COMPOUND-METRIC-DASHBOARD"
      runway_compound_analytics_dashboard_name = "DMP-${upper(var.environment_name)}-COMPOUND-LOG-ANALYTICS-DASHBOARD"

      # DataBricks Group
      etl_dbx_raw_writer_name = "sazDMP_ETL_Raw_Writer"
      etl_dbx_raw_writer_id   = "83343f8a-0765-408d-b1d8-3893a04c29c1"

      # Diagnostic Setting Group
      runway_key_vault_diagnostics_setting_name              = "runway_${var.environment_name}_keyvault_loganalytics_diagnostics"
      runway_data_factory_diagnostics_setting_name           = "runway_${var.environment_name}_adf_loganalytics_diagnostics"
      runway_sql_database_diagnostics_setting_name           = "runway_${var.environment_name}_sqldb_loganalytics_diagnostics"
      runway_servicebus_diagnostics_setting_name             = "runway_${var.environment_name}_servicebus_loganalytics_diagnostics"
      runway_fn_app_diagnostics_setting_name                 = "runway_${var.environment_name}_fnctionapp_loganalytics_diagnostics"
      runway_event_hub_diagnostics_setting_name              = "runway_${var.environment_name}_eventhub_loganalytics_diagnostics"
      runway_event_topic_diagnostics_setting_name            = "runway_${var.environment_name}_eventtopic_loganalytics_diagnostics"
      runway_fnapp_serviceplan_diagnostics_setting_name      = "runway_${var.environment_name}_serviceplan_loganalytics_diagnostics"
      runway_metastore_sql_database_diagnostics_setting_name = "runway_${var.environment_name}_metastore_sqldb_loganalytics_diagnostics"

      # DataFactory Group
      runway_adf_name           = ["dmp-adf-runway-${var.environment_name}-001"]
      runway_shared_adf_name    = "dmp-adf-runway-shr-${var.environment_name}-001"
      ccpa_adf_name             = "dmp-adf-ccpa-${var.environment_name}-001"
      runway_shared_adf_ir_name = "dmp-adf-runway-shr-eastus2-${var.environment_name}-001"
      runway_onprem_adf_ir_name = "dmp-adf-runway-shr-onprem-${var.environment_name}-001"

      # DataFactory Virtual Machine Group
      runway_adf_vm_size                   = "Standard_DS3_v2"
      runway_adf_vm_admin_username         = "KRVMADMIN"
      runway_adf_ir_vm_install_script_name = "Install-IntegrationRuntime.ps1"

      # Eventhub Group
      runway_event_grid_name          = "dmp-egtopic-runway-status-${var.environment_name}-001"
      runway_event_hub_namespace_name = "dmp-ehns-runway-${var.environment_name}-001"
      runway_event_hub_logs_name      = "dmp-ehub-adf-runway-logs-${var.environment_name}-001"

      # Function App Group
      runway_app_service_name                      = "dmp-fnapp-svcplan-runway-${var.environment_name}-001"
      runway_ingestion_fn_app_storage_account_name = "dmpstfnapprunway${var.environment_name}001"
      runway_ingestion_fn_app_name                 = ["dmp-fnapp-runway-${var.environment_name}-001"]

      # GCP Backload Group
      runway_gcp_adf_name      = "dmp-adf-gcp-bkld-${var.environment_name}-001"
      runway_gcp_keyvault_name = "dmp-kv-gcp-bkld-${var.environment_name}-001"
      runway_gcp_storage_name  = "dmpgcpbackload${var.environment_name}"

      # Key Vault Group
      runway_keyvault_name                                   = "dmp-kv-runway-${var.environment_name}-001"
      enableQRadar                                           = 1
      runway_ingestion_qradar_key_vault_log_name             = "runway-keyvault-${var.environment_name}-qradar-logs"
      runway_ingestion_qradar_eventhub_name                  = "insights-operational-logs"
      runway_ingestion_qradar_eventhub_authorization_rule_id = "/subscriptions/2912a3d7-4fae-4252-9f75-670d4c28b63a/resourceGroups/cloud-monitoring/providers/Microsoft.EventHub/namespaces/qradar-eventhub-namespace/authorizationRules/RootManageSharedAccessKey"

      # Observer Group - Resources that Monitor the Platform and Process
      runway_observer_storage_account_name = "dmpstobserver${var.environment_name}"
      runway_observer_adf_name             = "dmp-adf-runway-observer-${var.environment_name}-001"

      # log Analytics Group
      runway_loganalytics_workspace_name = "dmp-la-runway-${var.environment_name}-001"

      # Servicebus Group
      runway_servicebus_namespace_name                                 = "dmp-sbus-runway-${var.environment_name}-001"
      runway_servicebus_topic_name                                     = "dmp-sbt-runway-${var.environment_name}-001"
      runway_integration_event_servicebus_topic_name                   = "dmp-sbt-integration-events-${var.environment_name}-001"
      runway_integration_event_servicebus_subscription_process_monitor = "process-monitor-subscription"
      runway_servicebus_subscription_pipeline_runner                   = "adf-pipeline-runner-subscription"
      runway_servicebus_subscription_pipeline_cleaner                  = "adf-pipeline-cleaner-subscription"
      runway_servicebus_subscription_execution_status                  = "execution-status-subscription"
      runway_servicebus_subscription_message_logger                    = "message-logger-subscription"
      runway_servicebus_subscription_forward_integration_events        = "integration-event-forwarding-subscription"
      runway_servicebus_subscription_max_delivery_count                = "3"
      runway_servicebus_subscription_default_message_ttl               = "P1D"
      runway_servicebus_subscription_lock_duration                     = "PT5M"
      runway_servicebus_subscription_auto_delete_on_idle               = "P364819DT12H30M5S"
      runway_servicebus_subscription_process_monitor                   = "process-monitor-subscription"
      runway_servicebus_subscription_workflow_invoker                  = "workflow-invoker-subscription"

      # SQL Server Group
      runway_sql_server_name                           = "dmp-sql-runway-${var.environment_name}-001"
      runway_sql_server_admin_sql_login_name           = "admin-sql-admin-${var.environment_name}-001"
      runway_sql_server_audit_log_storage_account_name = "dmpsqlauditlog${var.environment_name}"

      # SQL Database Group
      runway_config_sql_database_name = "dmp-sqldb-runway-configuration"

      # Premium P1 tire has dtu valu 150 
      runway_config_sql_requested_service_objective_name = "P1"

      # logic app resource health monitor 
      la_azurerm_template_deployment_name = "dmp_la_arm_health_monitor_${var.environment_name}"
      la_health_app_name                  = "dmp_la_resource_health_monitor_${var.environment_name}"
      la_app_subscription_id              = var.subscription_id
      la_health_webhook_url               = "http://35.190.24.217/v1/templated/" # override it for prod env 

      # logic app long running pipeline monitor 
      la_long_running_jobs_azurerm_template_name = "dmp_la_arm_long_running_pipeline_monitor_${var.environment_name}"
      la_long_running_jobs_app_name              = "dmp_la_long_running_pipeline_monitor_${var.environment_name}"
      la_long_running_jobs_webhook_url           = "http://35.190.24.217/v1/templated/" # override it for prod env 

      # Alert Configuration parameters for multiple azure service groups 
      runway_alert_action_group_name               = "dmp_ops_support_${var.environment_name}_alert"
      runway_alert_action_group_email_name         = "dmp_ops_support_${var.environment_name}_alert_group"
      runway_alert_action_group_name_ticket_major  = "dmp_ops_support_${var.environment_name}_alert_ticket_major"
      runway_alert_action_group_webhook_major_name = "dmp_ops_support_${var.environment_name}_webhook_ticket_major"
      runway_alert_action_group_ticket_email_name  = "dmp_ops_support_${var.environment_name}_alert_ticket_group"
      runway_alert_action_group_name_ticket_minor  = "dmp_ops_support_${var.environment_name}_alert_ticket_minor"
      runway_alert_action_group_webhook_minor_name = "dmp_ops_support_${var.environment_name}_webhook_ticket_minor"
      ops_alert_action_group_name_ticket_major_name = "dmp_ops_support_${var.environment_name}_custom_alert_ticket_major" 
      ops_alert_action_group_webhook_major_name     = "dmp_ops_support_${var.environment_name}_custom_webhook_ticket_major"

      runway_alert_functionapp_http_name            = "dmp_alert_${var.environment_name}_funapp_http4xx"
      runway_alert_functionapp_responsetime_name    = "dmp_alert_${var.environment_name}_funapp_ResponseTime"
      runway_alert_functionapp_http5x_name          = "dmp_alert_${var.environment_name}_funapp_Http5xx"
      runway_alert_servicebus_usererror_name        = "dmp_alert_${var.environment_name}_sbus_UserErrors"
      runway_alert_servicebus_servererror_name      = "dmp_alert_${var.environment_name}_sbus_ServerErrors"
      runway_alert_servicebus_deadmessage_name      = "dmp_alert_${var.environment_name}_sbus_DeadletteredMessages"
      runway_alert_servicebus_cpuxns_name           = "dmp_alert_${var.environment_name}_sbus_CPUXNS"
      runway_alert_sql_storagepercent_name          = "dmp_alert_${var.environment_name}_sql_storage_percent"
      runway_alert_sql_cpupercent_name              = "dmp_alert_${var.environment_name}_sql_cpu_percent"
      runway_alert_sql_cpupercent_hi_name           = "dmp_alert_${var.environment_name}_sql_cpu_percent_hi"
      runway_alert_sql_deadlock_name                = "dmp_alert_${var.environment_name}_sql_deadlock"
      runway_alert_sql_dataread_name                = "dmp_alert_${var.environment_name}_sql_physical_data_read"
      runway_alert_sql_session_name                 = "dmp_alert_${var.environment_name}_sql_sessions_percent"
      runway_alert_sql_worker_name                  = "dmp_alert_${var.environment_name}_sql_workers_percent"
      runway_alert_sql_failconnection_name          = "dmp_alert_${var.environment_name}_sql_connection_failed"
      runway_alert_sql_firewall_name                = "dmp_alert_${var.environment_name}_sql_blocked_by_firewall"
      runway_alert_sql_datalake_storagepercent_name = "dmp_alert_${var.environment_name}_sql_datalake_storage_percent"
      runway_alert_sql_datalake_cpupercent_name     = "dmp_alert_${var.environment_name}_sql_datalake_cpu_percent"
      runway_alert_sql_datalake_cpupercent_hi_name  = "dmp_alert_${var.environment_name}_sql_datalake_cpu_percent_hi"
      runway_alert_sql_datalake_deadlock_name       = "dmp_alert_${var.environment_name}_sql_datalake_deadlock"
      runway_alert_sql_datalake_dataread_name       = "dmp_alert_${var.environment_name}_sql_datalake_physical_data_read"
      runway_alert_sql_datalake_session_name        = "dmp_alert_${var.environment_name}_sql_datalake_sessions_percent"
      runway_alert_sql_datalake_worker_name         = "dmp_alert_${var.environment_name}_sql_datalake_workers_percent"
      runway_alert_sql_datalake_failconnection_name = "dmp_alert_${var.environment_name}_sql_datalake_connection_failed"
      runway_alert_sql_datalake_firewall_name       = "dmp_alert_${var.environment_name}_sql_datalake_blocked_by_firewall"
      runway_alert_adls_datalake_availability_name  = "dmp_alert_${var.environment_name}_adls_availability"

      runway_alert_adf_piplinefail_name           = "dmp_alert_${var.environment_name}_adf_pipelinefailedruns"
      runway_alert_adf_triggerfail_name           = "dmp_alert_${var.environment_name}_adf_triggerfailedruns"
      runway_alert_adf_piplinefail_name_no_ticket = "dmp_alert_${var.environment_name}_adf_pipelinefailedruns_no_ticket"
      runway_alert_audit_sql_create_name          = "dmp_alert_${var.environment_name}_sql_create_update"
      runway_alert_audit_sql_delete_name          = "dmp_alert_${var.environment_name}_sql_delete"
      runway_alert_audit_sql_rename_name          = "dmp_alert_${var.environment_name}_sql_rename"
      runway_alert_audit_sql_datalake_create_name = "dmp_alert_${var.environment_name}_sql_datalake_create_update"
      runway_alert_audit_sql_datalake_delete_name = "dmp_alert_${var.environment_name}_sql_datalake_delete"
      runway_alert_audit_sql_datalake_rename_name = "dmp_alert_${var.environment_name}_sql_datalake_rename"
      runway_alert_keyvault_available_name        = "dmp_alert_${var.environment_name}_keyvault_Availability"
      runway_alert_keyvault_latency_name          = "dmp_alert_${var.environment_name}_keyvault_Latency"
      runway_alert_keyvault_error_name            = "dmp_alert_${var.environment_name}_keyvault_Total_Error_Codes"

      #Added scheduled alert for P2 datasets failed pipelines 
      scheduled_alert_la_failed_pipeline = "dmp_scheduled_alert_${var.environment_name}_la_failed_pipelines"

      runway_alert_shr_adf_ir_availability_name = "dmp_alert_${var.environment_name}_shr_adf_IR_nodecount"
      runway_alert_health_name                  = "dmp_alert_${var.environment_name}_service_health"
      runway_alert_funapp_exceptions_name       = "dmp_alert_${var.environment_name}_funapp_exceptions"
      scope_subscription_level                  = ["/subscriptions/${var.subscription_id}"]

      #Group access to keyvault
      runway_developer_group_id = "ab81136e-968f-492d-8f64-f22cbdea9269" #gAZ5839DMPDev 

      # Operations resources
      operations_infra_url = "https://prod-22.eastus2.logic.azure.com:443/workflows/b8e22947c4c34142912bfe77a5cf50ab/triggers/manual/paths/invoke?api-version=2016-10-01"
    }


    build = {
      # Enterprise Ingestion Resource group
      runway_deployer_service_principal_id    = "3958837e-cce0-45eb-ac7a-aae095b5817e" #dmp-nonprod-deployer
      runway_provisioner_service_principal_id = "12881ce8-3bdb-4e19-b30a-f3811d769cc2" #svc-5839-dmp-runway-build-d

      # Subnets
      runway_functions_subnet = local.subscription.nonprod.runway_build_functions_subnet

      # DataBricks Group
      runway_dbx_resource_group_name = "rg-5766-dmpetl-np"
      runway_dbx_instance_url        = "https://adb-841836083790816.16.azuredatabricks.net"
      runway_dbx_workspace_name      = "dmp-5766-dev-db1"
      runway_dbx_instance_pool_name  = "dmp-pool-build"
      runway_dbx_secret_scope_name   = "RUNWAY-SCOPE-BUILD"

      # DataFactory Group
      # The shared ADF name is incorrect and the DataFactory in build needs to be deleted and recreated to match dev, test, stage, and prod.
      runway_adf_name           = ["dmp-adf-runway-build-001"]
      runway_shared_adf_name    = "dmp-adf-runway-shr-eastus2-build-001"
      runway_shared_adf_ir_name = "dmp-adf-runway-shr-eastus2-build-001"

      # DataFactory Virtual machine group
      runway_adf_vm_name         = ["n060dmpdf701", "n060dmpdf702"]
      runway_adf_vm_nic_name     = ["n060dmpdf701-nic", "n060dmpdf702-nic"]
      runway_adf_vm_os_disk_name = ["n060dmpdf701-osdisk", "n060dmpdf702-osdisk"]
      runway_adf_vm_subnet_id    = local.subscription.nonprod.runway_subnet_adfintegrationruntime

      # Eventhub Group
      runway_event_hub_namespace_subnet_id = local.subscription.nonprod.runway_subnet_adfintegrationruntime

      # Function App Group
      runway_ingestion_fn_app_storage_account_ip_rules   = []
      runway_ingestion_fn_app_storage_account_subnet_ids = []
      runway_ingestion_fn_app_swift_subnet               = local.subscription.nonprod.runway_build_functions_subnet
      runway_app_service_plan_size                       = "P1v2"

      # GCP Group
      # This exists as an environment level local because the name had to be shortened under 24 characters
      runway_gcp_keyvault_name = "dmp-kv-gcp-bld-${var.environment_name}-001"

      # Servicebus Group
      # runway_servicebus_namespace_name
      runway_servicebus_namespace_network_rules = [
        {
          subnet_id                            = local.subscription.nonprod.runway_subnet_adfintegrationruntime
          ignore_missing_vnet_service_endpoint = false
        },
        {
          subnet_id                            = local.subscription.nonprod.runway_build_functions_subnet
          ignore_missing_vnet_service_endpoint = false
        }
      ]
      runway_servicebus_namespace_ip_rules = ["158.48.0.0/16", "104.209.253.237", "104.46.96.136", "40.70.147.11", "40.70.28.239", "52.177.119.222", "52.177.127.186", "52.177.22.136", "52.177.23.145", "52.184.147.38", "52.184.147.42", "52.251.115.213", "104.209.219.240", "52.251.114.9", "13.77.69.217", "40.123.55.50", "40.70.147.13", "104.208.138.157", "104.46.127.127", "52.251.126.49", "104.209.194.156", "52.251.115.213", "104.209.219.240", "52.251.114.9", "13.77.69.217", "40.123.55.50"]

      # SQL server Group
      runway_sql_admin_login_name          = "gAD5839configdbownerD"
      runway_sql_active_directory_admin_id = "a6520530-6a9f-4904-83dd-e6796d244046" #gAZ5839configdbownerD
      runway_sql_subnet_ids = [
        local.subscription.nonprod.runway_subnet_adfintegrationruntime,
        local.subscription.nonprod.runway_build_functions_subnet,
        local.subscription.nonprod.dq_dev_dbx_subnet
      ]

      # Storage Group
      runway_adls_unrestricted_reader = "1530cd3a-7adb-40d7-927c-6ecce4671c17" #gAZ5839UnrestrictedReaderD
      runway_adls_unrestricted_writer = "95d27cfa-a82b-4f97-84fe-8ea62332d14e" #gAZ5839datalakeunrestrictedwriterD

      # Observer Group
      runway_observer_storage_account_subnet = [
        local.subscription.nonprod.tsacentralus_azdocentralus_id,
        local.subscription.nonprod.runway_subnet_adfintegrationruntime,
        local.subscription.nonprod.runway_build_dbx_subnet,
        local.subscription.nonprod.dq_dev_dbx_subnet

      ]
    }

    dev = {
      # Enterprise Ingestion Resource group
      runway_deployer_service_principal_id    = "3958837e-cce0-45eb-ac7a-aae095b5817e" #dmp-nonprod-deployer
      runway_provisioner_service_principal_id = "12881ce8-3bdb-4e19-b30a-f3811d769cc2" #svc-5839-dmp-runway-build-d

      # Subnets
      runway_functions_subnet = local.subscription.nonprod.runway_dev_functions_subnet

      # DataBricks Group
      runway_dbx_resource_group_name = "rg-5766-dmpetl-np"
      runway_dbx_instance_url        = "https://adb-841836083790816.16.azuredatabricks.net"
      runway_dbx_workspace_name      = "dmp-5766-dev-db1"
      runway_dbx_instance_pool_name  = "dmp-pool"
      runway_dbx_secret_scope_name   = "RUNWAY-SCOPE-DEV"

      # DataFactory Virtual machine group
      runway_adf_vm_name         = ["n060dmpdf801", "n060dmpdf802"]
      runway_adf_vm_nic_name     = ["n060dmpdf801-nic", "n060dmpdf802-nic"]
      runway_adf_vm_os_disk_name = ["n060dmpdf801-osdisk", "n060dmpdf802-osdisk"]
      runway_adf_vm_subnet_id    = local.subscription.nonprod.runway_subnet_adfintegrationruntime

      # Eventhub Group
      runway_event_hub_namespace_subnet_id = local.subscription.nonprod.runway_subnet_adfintegrationruntime

      # Fuction App Group
      runway_ingestion_fn_app_storage_account_ip_rules   = []
      runway_ingestion_fn_app_storage_account_subnet_ids = []
      runway_ingestion_fn_app_swift_subnet               = local.subscription.nonprod.runway_dev_functions_subnet
      runway_app_service_plan_size                       = "P2v2"

      # Servicebus Group
      runway_servicebus_namespace_network_rules = [
        {
          subnet_id                            = local.subscription.nonprod.runway_subnet_adfintegrationruntime
          ignore_missing_vnet_service_endpoint = false
        },
        {
          subnet_id                            = local.subscription.nonprod.runway_dev_functions_subnet
          ignore_missing_vnet_service_endpoint = false
        }
      ]
      runway_servicebus_namespace_ip_rules = ["158.48.0.0/16", "104.209.253.237", "104.46.96.136", "40.70.147.11", "40.70.28.239", "52.177.119.222", "52.177.127.186", "52.177.22.136", "52.177.23.145", "52.184.147.38", "52.184.147.42", ]

      # SQL server Group
      runway_sql_admin_login_name          = "gAD5839configdbownerD"
      runway_sql_active_directory_admin_id = "a6520530-6a9f-4904-83dd-e6796d244046" #gAZ5839configdbownerD
      runway_sql_subnet_ids = [
        local.subscription.nonprod.runway_subnet_adfintegrationruntime,
        local.subscription.nonprod.runway_dev_functions_subnet,
        local.subscription.nonprod.dq_dev_dbx_subnet
      ]

      # Storage Group
      runway_adls_unrestricted_reader = "1530cd3a-7adb-40d7-927c-6ecce4671c17" #gAZ5839UnrestrictedReaderD
      runway_adls_unrestricted_writer = "95d27cfa-a82b-4f97-84fe-8ea62332d14e" #gAZ5839datalakeunrestrictedwriterD

      # Observer Group
      runway_observer_storage_account_subnet = [
        local.subscription.nonprod.tsacentralus_azdocentralus_id,
        local.subscription.nonprod.runway_subnet_adfintegrationruntime,
        local.subscription.nonprod.runway_dev_dbx_subnet,
        local.subscription.nonprod.dq_dev_dbx_subnet
      ]
    }

    test = {
      # Enterprise Ingestion Resource group
      runway_deployer_service_principal_id    = "3958837e-cce0-45eb-ac7a-aae095b5817e" #dmp-nonprod-deployer
      runway_provisioner_service_principal_id = "672c75e8-d07d-42a5-ba44-07a34bbbf8db" #svc-5839-dmp-runway-build-t

      # Subnets
      runway_functions_subnet = local.subscription.nonprod.runway_test_functions_subnet

      # DataBricks Group
      runway_dbx_resource_group_name = "rg-5766-dmpetl-np"
      runway_dbx_instance_url        = "https://adb-841836083790816.16.azuredatabricks.net"
      runway_dbx_workspace_name      = "dmp-5766-dev-db1"
      runway_dbx_instance_pool_name  = "dmp-pool-test"
      runway_dbx_secret_scope_name   = "RUNWAY-SCOPE-TEST"

      # DataFactory Virtual machine group
      runway_adf_vm_name         = ["n060dmpdf401", "n060dmpdf402"]
      runway_adf_vm_nic_name     = ["n060dmpdf401-nic", "n060dmpdf402-nic"]
      runway_adf_vm_os_disk_name = ["n060dmpdf401-osdisk", "n060dmpdf402-osdisk"]
      runway_adf_vm_subnet_id    = local.subscription.nonprod.runway_subnet_adfintegrationruntime

      # Eventhub Group
      runway_event_hub_namespace_subnet_id = local.subscription.nonprod.runway_subnet_adfintegrationruntime

      # Fuction App Group
      runway_ingestion_fn_app_storage_account_ip_rules   = []
      runway_ingestion_fn_app_storage_account_subnet_ids = []
      runway_ingestion_fn_app_swift_subnet               = local.subscription.nonprod.runway_test_functions_subnet
      runway_app_service_plan_size                       = "P1v2"

      # Servicebus Group
      runway_servicebus_namespace_network_rules = [
        {
          subnet_id                            = local.subscription.nonprod.runway_subnet_adfintegrationruntime
          ignore_missing_vnet_service_endpoint = false
        },
        {
          subnet_id                            = local.subscription.nonprod.runway_test_functions_subnet
          ignore_missing_vnet_service_endpoint = false
        }
      ]
      runway_servicebus_namespace_ip_rules = ["158.48.0.0/16", "104.209.253.237", "104.46.96.136", "40.70.147.11", "40.70.28.239", "52.177.119.222", "52.177.127.186", "52.177.22.136", "52.177.23.145", "52.184.147.38", "52.184.147.42", ]

      # SQL server Group
      runway_sql_admin_login_name          = "gAD5839configdbownerT"
      runway_sql_active_directory_admin_id = "07293212-f0ee-49d2-abf1-372faacd7691" #gAZ5839configdbownerT
      runway_sql_subnet_ids = [
        local.subscription.nonprod.runway_subnet_adfintegrationruntime,
        local.subscription.nonprod.runway_test_functions_subnet,
        local.subscription.nonprod.dq_test_dbx_subnet
      ]

      # Storage Group
      runway_adls_unrestricted_reader = "9104a355-e6a2-42f7-b34f-a20785d69520" #gAZ5839UnrestrictedReaderT
      runway_adls_unrestricted_writer = "0341dea5-fade-4330-aee0-7edd9f89cf0e" #gAZ5839datalakeunrestrictedwriterT

      # Observer Group
      runway_observer_storage_account_subnet = [
        local.subscription.nonprod.tsacentralus_azdocentralus_id,
        local.subscription.nonprod.runway_subnet_adfintegrationruntime,
        local.subscription.nonprod.runway_test_dbx_subnet,
        local.subscription.nonprod.dq_test_dbx_subnet
      ]
    }

    stage = {
      # Enterprise Ingestion Resource group
      runway_deployer_service_principal_id    = "dd4e3fc0-98cd-466c-97ab-01bcbd206313" #dmp-prod-deployer
      runway_provisioner_service_principal_id = "3b05bdd5-6fe1-4359-8a20-bf787b1374d8" #svc-5839-dmp-runway-build-s

      # Subnets
      runway_functions_subnet = local.subscription.prod.runway_stage_functions_subnet

      # DataBricks Group
      runway_dbx_resource_group_name = "rg-dmp-etl-dbx-np"
      runway_dbx_instance_url        = "https://adb-6480714072025413.13.azuredatabricks.net/"
      runway_dbx_workspace_name      = "dmp-etl-stg-dbxws-001"
      runway_dbx_instance_pool_name  = "dmp-pool1"
      runway_dbx_secret_scope_name   = "RUNWAY-SCOPE-STAGE"
      runway_dbx_subscription_id     = local.subscription.nonprod.subscription_id

      # DataFactory Virtual machine group
      runway_adf_vm_name         = ["n060dmpdf201", "n060dmpdf202"]
      runway_adf_vm_nic_name     = ["n060dmpdf201-nic", "n060dmpdf202-nic"]
      runway_adf_vm_os_disk_name = ["n060dmpdf201-osdisk", "n060dmpdf202-osdisk"]
      runway_adf_vm_subnet_id    = local.subscription.prod.runway_subnet_adfintegrationruntime

      # Eventhub Group
      runway_event_hub_namespace_subnet_id = local.subscription.prod.runway_subnet_adfintegrationruntime

      # Fuction App Group
      runway_ingestion_fn_app_storage_account_ip_rules   = []
      runway_ingestion_fn_app_storage_account_subnet_ids = []
      runway_ingestion_fn_app_swift_subnet               = local.subscription.prod.runway_stage_functions_subnet
      runway_app_service_plan_size                       = "P2v2"

      # GCP Group
      # This exists as an environment level local because the name had to be shortened under 24 characters
      runway_gcp_keyvault_name = "dmp-kv-gcp-bld-${var.environment_name}-001"

      # Servicebus Group
      runway_servicebus_namespace_network_rules = [
        {
          subnet_id                            = local.subscription.prod.runway_subnet_adfintegrationruntime
          ignore_missing_vnet_service_endpoint = false
        },
        {
          subnet_id                            = local.subscription.prod.runway_stage_functions_subnet
          ignore_missing_vnet_service_endpoint = false
        }
      ]
      runway_servicebus_namespace_ip_rules = ["158.48.0.0/16"]

      # SQL server Group
      runway_sql_admin_login_name          = "gAD5839configdbownerS"
      runway_sql_active_directory_admin_id = "a17db2f7-5571-4e5a-bd9a-8f9cf8085253" #gAZ5839configdbownerS
      runway_sql_subnet_ids = [
        local.subscription.prod.runway_subnet_adfintegrationruntime,
        local.subscription.prod.runway_stage_functions_subnet
      ]

      # Storage Group
      runway_adls_unrestricted_reader = "815af28c-c40d-4894-b332-551cc9c3bb85" #gAZ5839UnrestrictedReaderS
      runway_adls_unrestricted_writer = "84b1351f-2289-4272-9e33-381ecf8bf786" #gAZ5839datalakeunrestrictedwriterS

      # Observer Group
      runway_observer_storage_account_subnet = [
        local.subscription.prod.tsacentralus_azdocentralus_id,
        local.subscription.prod.runway_subnet_adfintegrationruntime,
        local.subscription.prod.runway_stage_dbx_subnet,
        local.subscription.prod.dq_prod_dbx_subnet
      ]
    }

    prod = {
      # Enterprise Ingestion Resource group
      runway_deployer_service_principal_id    = "dd4e3fc0-98cd-466c-97ab-01bcbd206313" #dmp-prod-deployer
      runway_provisioner_service_principal_id = "04060fef-f695-4b5d-94cc-a32b1bef5191" #svc-5839-dmp-runway-build-p

      # Subnets
      runway_functions_subnet = local.subscription.prod.runway_prod_functions_subnet

      runway_datalake_storage_account_id = "/subscriptions/d4ed766d-813e-4037-b448-2d1dd7ef81f6/resourceGroups/rg-DMPEnterpriseDataLake-prod-001/providers/Microsoft.Storage/storageAccounts/dmpdatalake"
      runway_alert_ticket_major_url      = "http://35.190.24.217/v1/azure-dbx?token=5QZChXV1RTRHNTzU_Zed&infraGroup=INF-DMP-Support%20%28Data%20Management%20Platform%29&severity=major"
      runway_alert_ticket_minor_url      = "http://35.190.24.217/v1/azure-dbx?token=5QZChXV1RTRHNTzU_Zed&infraGroup=INF-DMP-Support%20%28Data%20Management%20Platform%29&severity=minor"

      #Custom Alert URL
      ops_alert_ticket_major_url         = "http://35.190.24.217/v1/templated?token=5QZChXV1RTRHNTzU_Zed&infraGroup=INF-DMP-Support%20%28Data%20Management%20Platform%29&template=dmp-ops-support-gen&severity=major"

      # webhook url override for health monitor logic app
      la_health_webhook_url = "http://35.190.24.217/v1/templated?token=5QZChXV1RTRHNTzU_Zed&infraGroup=INF-DMP-Support%20%28Data%20Management%20Platform%29&template=dmp-healthcheck&severity=major"

      # webhook url override for logic app long running pipeline monitor logic app 
      la_long_running_jobs_webhook_url = "http://35.190.24.217/v1/templated?token=5QZChXV1RTRHNTzU_Zed&infraGroup=INF-DMP-Support%20%28Data%20Management%20Platform%29&template=dmp-ops-support-gen&severity=minor"

      # datalake prod name 
      runway_datalake_storage_account_name = "dmpdatalake"

      # DataBricks Group
      runway_dbx_resource_group_name = "rg-dmp-etl-dbx-prod"
      runway_dbx_instance_url        = "https://adb-8187677146320823.3.azuredatabricks.net"
      runway_dbx_workspace_name      = "dmp-etl-prod-dbxws-001"
      runway_dbx_instance_pool_name  = "dmp-pool1"
      runway_dbx_secret_scope_name   = "RUNWAY-SCOPE-PROD"

      # DataFactory Virtual machine group
      runway_adf_vm_size         = "Standard_D8s_v3"
      runway_adf_vm_name         = ["n060dmpdf101", "n060dmpdf102"]
      runway_adf_vm_nic_name     = ["n060dmpdf101-nic", "n060dmpdf102-nic"]
      runway_adf_vm_os_disk_name = ["n060dmpdf101-osdisk", "n060dmpdf102-osdisk"]
      runway_adf_vm_subnet_id    = local.subscription.prod.runway_subnet_adfintegrationruntime

      # Eventhub Group
      runway_event_hub_namespace_subnet_id = local.subscription.prod.runway_subnet_adfintegrationruntime

      # Fuction App Group
      runway_ingestion_fn_app_storage_account_ip_rules   = []
      runway_ingestion_fn_app_storage_account_subnet_ids = []
      runway_ingestion_fn_app_swift_subnet               = local.subscription.prod.runway_prod_functions_subnet
      runway_app_service_plan_size                       = "P2v2"

      # Servicebus Group
      az-asb-name       = "dmp-sbus-runway-prod-001"
      az-asb-topic-name = "dmp-sbt-runway-prod-001"
      runway_servicebus_namespace_network_rules = [
        {
          subnet_id                            = local.subscription.prod.runway_subnet_adfintegrationruntime
          ignore_missing_vnet_service_endpoint = false
        },
        {
          subnet_id                            = local.subscription.prod.runway_prod_functions_subnet
          ignore_missing_vnet_service_endpoint = false
        }
      ]
      runway_servicebus_namespace_ip_rules = ["158.48.0.0/16", "104.46.110.22", "104.46.111.105", "137.116.88.213", "23.101.144.218", "23.101.158.48", "40.79.73.27", "40.79.74.47", "40.79.79.209", ]

      # SQL server Group
      runway_sql_admin_login_name          = "gAD5839configdbownerD"
      runway_sql_active_directory_admin_id = "fe2d6ce8-63f9-4e3e-91df-47aa9c2df2eb" #gAZ5839configdbownerP
      runway_sql_subnet_ids = [
        local.subscription.prod.runway_subnet_adfintegrationruntime,
        local.subscription.prod.runway_prod_functions_subnet,
        local.subscription.prod.dq_prod_dbx_subnet
      ]


      # Storage Group
      runway_adls_unrestricted_reader = "59e467ff-5e86-48a6-a3f3-759d689624b9" #gAZ5839UnrestrictedReaderP
      runway_adls_unrestricted_writer = "6ecc4f6e-b5dd-4346-8f12-eb0788260b1a" #gAZ5839datalakeunrestrictedwriterP

      # Observer Group
      runway_observer_storage_account_subnet = [
        local.subscription.prod.tsacentralus_azdocentralus_id,
        local.subscription.prod.runway_subnet_adfintegrationruntime,
        local.subscription.prod.runway_prod_dbx_subnet,
        local.subscription.prod.dq_prod_dbx_subnet
      ]

      # Operations resources
      operations_infra_url = "https://prod-33.eastus2.logic.azure.com:443/workflows/c1f3c090640f480b99af210971b3b2cb/triggers/manual/paths/invoke?api-version=2016-10-01"
    }
  }

  env = merge(
    local.subscription[var.subscription],
    local.environment["common"],
    local.environment[var.environment_name],
  )
}
