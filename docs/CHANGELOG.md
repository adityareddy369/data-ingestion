All notable changes to this project will be documented in this file

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## UNRELEASED
### Added

### Changed
- Updated trigger and pr in azure-pipelines.yml

### Removed

### Fixed

[1.1.25] - 2021-06-03

### Added
- SQL security fix - sqlserver.tf

### Changed
- Fix dev and test conditions to include startsWith for tags in azure-pipelines.yaml
- Removed develop as an option for test in azure-pipelines.yaml
- Change of alert template for ocado alerts
### Removed

### Fixed

[1.1.24] - 2021-05-27

### Changed
- Re-add planConditional and condition 
- Upgrade SQL Server to MS SQL Resources

[1.1.23rc2] - 2021-05-25
### Changed
- Remove planConditional and conditional as a workaround for a prod release (condition not working properly for Dev) 

[1.1.23] - 2021-05-25

### Changed
- updated health alert script 

### Fixed
- bug fix on long running pipeline logic app issue

[1.1.22] - 2021-05-24

### Added
- Added function app cli commands to disable and enable the dmp-fnapp-runway-XXX-001 ExecutionRunner function in cicd/functionapp

### Changed
- Added parameters to set https only and disable ftps in serviceplanfnapp.tf
- Added "trigger: none" to yaml that executes function app cli commands so the pipelines are only triggered manually.
- Changed trigger to none in adf-integration-image.yaml and azure-pipelines.yaml so the pipelines are only triggered manually.
- **Updated azure-pipelines.yaml so that we can only deploy to Dev and Test from a tag, main, or the new develop branch.**
  - Feature branches can be deployed to Build
  - When ready to deploy to Dev and Test, merge the feature branch to the new **develop** branch
  - When ready to deploy to Stage and Prod, merge the feature branch to main

[1.1.21] - 2021-05-19
### Changed
- Upgraded terraform version to 14.11 and azurerm version to 2.57.0

[1.1.20] - 2021-05-19
### Added
- Added ADF Integration Runtime Image creation pipeline using Packer and Ansible
- Added function app cli commands to assist with deploys for dmp-fnapp-runway-XXX-001 in cicd/functionapp

### Changed
- Increased FUNCTIONS_WORKER_PROCESS_COUNT from 4 to 6 in serviceplanfnapp.tf
- Changed dmp-fnapp-runway-prod subnet to dmp-runway-prod-prod-eastus2


[1.1.19] - 2021-05-13
### Added
- Added environment variable with the value of the integration events service bus connection string
- Added runway provisioner service principals service connections and planConditional
- Add DQ subnets to observer storage
- Added logic app to monitor long running pipelines 

### Changed
- Changed the app service plan size in Build and test environment to P1v2
- Excluded the system error in adf alert script

[1.1.18] - 2021-05-06
### Added
Added in Compound Log Analytics Dashboard to ADF queries a line that prevents to show system error

### Changed
Changed datalake db high cpu usage alert’s threshold to dynamic criteria

### Fixed
Fixed in Compound Metrics Dashboard the sql data access issue.

## [1.1.17] - 2021-04-22

### Added
- Give DMP developers group access to observer storage account containers
- Allow DBX to access observer storage account

## [1.1.16rc2] - 2021-04-20

### Fixed
- Fixed dbx access issue in stage env
- 
## [1.1.16] - 2021-04-20

### Added
- Added runaway service bus subscription for process monitor
- Added integration events service bus subscription for process monitor
- Added environment variable for functions to read process monitor integration events subscription name
- Added environment variable with operation's Infra alerting URL

- Added az cli script to migrate runway applications insights to log analytics workspace
- Added GitHub integration to the CCPA ADF Pipeline in Terraform
- Added keyvault policy for new runway service principals
- Added logic app arm template for health monitor
- Added alert for functionapp exceptions and log analytics alert
- 
### Changed
- updated the variable runway_datalake_storage_account_name in locals.tf
- 
## [1.1.15] - 2021-04-14

### Added
- Observer Storage Account and ADF Instance for exporting DQ Metrics
- Added role databricks contributor access to datafactory
- Added runway_dbx_subscription_id variable under common environment section and added nonprod subscription value to this variable for stage env

### Changed
- Modified Create-DbxLinkedService.ps1 to use managed identity instead of access token
- Modified the runway_ingestion_script_create_or_update_databricks_ls resource creation dependency to databricks contributor access role provider resource creation
- Fix stage databricks pool id

## [1.1.14] - 2021-04-06

### Changed
- Upgrade azurerm to 2.51.0 to resolve key vault access policy issue

## [1.1.13] - 2021-04-06
- Added new subscription for process monitor

### Added
- ADF resource dmp-adf-ccpa-{env}-001
- Added SandBox Activities as disabled to event log for runway ADFs
- Added log analytics workspace id and key secrets in terraform

### Changed

- Updated the terraform code to remove deprecated warnings from the pipeline runs
- Increase Function App Service Plan from P1v2 to P2v2

### Removed
- Removed auto_delete_on_idle property from forward message topic subscription

## [1.1.12] - 2021-03-25

### Added
Added in Compound Log Analytics Dashboard ADF queries to bring visibility for run status and Function App queries about data analytics
Added in Alerts.tf new settings for service health alerts using ARM template: service issue alert and compound alert (planned maintenance, health advisories, security advisory).

### Removed
Removed alert:  dmp_alert_prod_service_health


## [1.1.11] - 2021-03-24

### Added
- Grant Config and Hive Metastore database access to Data Quality groups
- Add Data Quality subnets for config sql database 

### Changed
- upgraded self hosted IR runtime version in Install-IntegrationRuntime.ps1 script.
- Fix runway_dbx_instance_pool_name in dev and test
- Changed azurerm provider version to 2.48.0
- Added extended_auditing_policy back to runway_ingestion_sqlserver as a workaround to an azure_rm issue that was preventing the apply step from working

## [1.1.10] - 2021-02-24

### Added
- Added webhook connectivity to prod and non prod environments.
- Added dbx-spark-monitoring.yaml to deploy jars and scripts for log analytics monitoring

### Changed
- Changed powershell that deploys the Databricks linked service to include parameters for long analytics monitoring
- Fix stage databricks pool name and url

## [1.1.9] - 2021-02-16

### Added
- Added Runway SQL Admin Username to Key Vault for easier maintenance.

### Fixed
- Fixed Group Ids for gAZ5839datalakeunrestrictedwriterD and gAZ5839UnrestrictedReaderP
- Fixed Databricks Secret Scope Names to always be environment sensitive

## [1.1.8] - 2021-02-11

### Added
- Save full Configuration DB Connectionstring as a Key Vault secret
- added keyvault policy to access secrets by developer group

### Changed
- Removed pre init

### Removed

### Fixed

## [1.1.7] - 2021-02-05

### Added

### Changed
- Reset SQL Server Local Admin password

### Removed

### Fixed

## [1.1.6] - 2021-02-01

### Added
- Added code in keyvault.tf for sending keyvault logs to Qradar Eventhub

## [1.1.5] - 2021-01-29

### Changed
- Updated the terraform version to 0.14.5
- Updated the azurerm provider version to 2.26.0

## [1.1.4] - 2020-01-28

### Changed
- Updated the terraform version to 0.14.5
- Updated the azurerm provider version to 2.26.0

## [1.1.3] - 2020-01-27

### Changed
- Updated the azurerm provider version to 2.41.0

## [1.1.2] - 2020-01-27

### Added

### Changed
- Updated the terraform version to 0.14.5
### Removed

### Fixed

## [1.1.1] - 2020-01-20

### Added

### Changed
- Updated the YAML file to configure SQL Audit Settings for SQL Server
- Updated the SQLserver.tf to upgrade to Prmium Tier, configure Zone Redundant configuration for SQL Databases, SQLAuto tuning

### Removed

### Fixed

## [1.1.0] - 2020-01-20

### Added

### Changed
- We will create new release with hotfix and deploy the changes in next release.( 1.1.1 )
### Removed

### Fixed
-We noticed a small bug after doing deployment till dev env.

## [1.0.9] - 2020-12-17

### Added
- Added new alert group for P3/sev3 severity in alert_script_all.tf
- Added service health check alert in alert_script_all.tf
### Changed
- Updated all alert rules, action group parameters in alert_script_all.tf
- Made changes for some missing diagnostic settings configuration for SQL Database and ADF
### Removed

### Fixed


## [1.0.8] - 2020-12-16

### Changed
- Updated terraform template tag version to v0.5.6 in YAML definition
- Updated runway ADF VMs size to D8s_v3 in production environment

### Fixed
- Fixed object id for gAZ5839UnrestrictedReaderT

## [1.0.7] - 2020-12-01

### Added
- Added additional alert rule ("runway_ingestion_alert_adf_pipelinefailedRuns_no_ticket") for adf service in dmp_alert_all.tf script  
- Increase number of Python Worker processes in the Azure Function App to four.

### Changed
- Changed adf alert ("runway_ingestion_alert_adf_pipelinefailedRuns") threshold from 1 to 2 for alert with ticket in dmp_alert_all.tf script  
- Updated webhook url severity only for prod in locals.tf

### Removed
- Removed activity fail alert ("runway_ingestion_alert_adf_activityfailedRuns") for adf service in dmp_alert_all.tf script 

## [1.0.6] - 2020-11-30

### Added
- Added new Service Bus Topic to provide other services a way to consume Integration Events. 

### Changed
- Enable Soft Delete and Purge Protection for Keyvaults to comply with Cloud Services Policies.
- Removed unnecessary IP Restrictions from Function App storage accounts. 

### Notes
- Reversed change to use planConditional flag to selectively generate plans per environment. The template file needs an update in the conditional logic before it will work as expected. 

## [1.0.5] - 2020-11-11

### Added
- Updated master branch to main branch and changed all master reference to main in YAML pipeline
- [2020-11-04] Backed out modifications from [1.0.4] that would delete the Databricks linked service in ADF before recreating it to prevent impacting existing systems for    [DMPART-9977](https://jira.kroger.com/jira/secure/RapidBoard.jspa?rapidView=6808&projectKey=DMPART&view=detail&selectedIssue=DMPART-9977).
- Added compound-log-analytics-monitoring-dashboard.tf, loganalyticsworkspace.tf
- Added compound-metric-monitoring-dashboard-properties.json, compound-log-analytics-monitoring-dashboard-properties.json in scripts folder

### Changed
- Renamed terraform resources with new naming convention 
- State moved for all resources in tf-state file
- Updated the code in compound-metric-monitoring-dashboard.tf for dashboard deployment using template file 
- Updated resource names in alert_script_all.tf as per naming conventions
- Moved the diagnostic settings in loganalyticsworkspace.tf to individual service files
- Updated diagnostic settings for azure services in adf-runway.tf, eventhub.tf, servicebus.tf, serviceplanfnapp.tf and sqlserver.tf
- Updated the alert rule descriptions in alert_script_all.tf

### Removed
- Deleted empty files alert_script.tf, compound-monitoring-dashboard.tf, commondashboard.tf and dmp_alert_script.tf

### Fixed
- Fixed Typo in adf-runway.tf, servicebus.tf, serviceplanfnapp.tf and sqlserver.tf
- Enabled common alert schema for webhook in alert action group

## [1.0.4] - 2020-10-20

### Added
- Function App Subnet to the Build Env
- New spark configs for abfss:// pathing to ADLS Gen2

### Changed
- Reverted the tagging implementation due to a bug in downloading modules
- Added newClusterSparkConf to PowerShell script for Databricks Linked Service.
- Moved the stage environment to the production subscription
- Create-DbxLinkedService.ps1 to remove existing DBX linked service for all envs except PROD before recreating it. Also added new parameter for App Registration Object Id to execute storage access as (DbxLinkedServiceId).
- Updated adf-runway.tf to call Create-DbxLinkedService.ps1 with new parameter (DbxLinkedServiceId).
- Set Function App SCM_NO_REPOSITORY to remove source control reference and avoid Terraform Apply failing after code deployment. 
- Moved TF vars to TF locals

## [1.0.3] - 2020-09-17

### Added
- Added implementation to pull the tags using the module in tagging module git repo
- Added lob tag in variables.tf

## [1.0.3] - 2020-09-15

### Changed
- Azure Data Factory Integration Runtime and Key Vault Linked Service now managed by Terraform
- PowerShell script created to create DataBricks Linked Service (not possible in Terraform)
- Updated Terraform to 0.13.2
- Updated AzureRM Provider to 2.26.0

## [1.0.2] - 2020-09-02
### Changed
- `ENABLE_ORYX_BUILD` set to `false` and `SCM_DO_BUILD_DURING_DEPLOYMENT` set to `0` to prevent the function app from calling out to the Internet

## [1.0.1] - 2020-08-31

### Added
  - Added automation script for user creation on sql server.
    - Runs via postapply step in each environment
    - Added a var.yml file (which will have values for all env) to pass the required values to the template

## [1.0.0] - 2020-09-02

### Added
- Azure Pipelines
- App Insights
- DataFactory
- Event Grid, Event Hub
- Key Vault, access policies
- Service Bus Namespace, Service Bus Topic, Topic Subscriptions
- Service App Plan, Runway Function App
- SQL Server, Runway SQL Database
- ADF Integration Runtime Virtual Machine
- Role Assignments
- GCP resources
- Variables per environment
- README.md, CHANGELOG.md, CONTRIBUTING.md, PULL_REQUEST_TEMPLATE.md
