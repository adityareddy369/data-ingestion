# DMPEnterpriseDataIngestion
Holds Azure DevOps YAML and terraform configuration of resources that correlate to the infrastructure housed within the resource group rg-DMPEnterpriseDataIngestion-XXX-XX

This files can be used as a starter for Azure DevOps Pipelines deploying Azure resources using Terraform scripts.

## Deployment Pipeline

The deployment pipeline for this Terraform configuration can be found here:
[krogertechnology.dmp-enterprise-data-ingestion](https://dev.azure.com/KrogerTechnology/InsaneCloudPosse/_build?definitionId=218&_a=summary)

## Contents

- docs
    - Files that describe the repository
- ci-cd
    - Files that describe the build and deployment of resources within the repository
- terraform
    - variables
        - Environment specific variable files
    - gcp
        - gcp-datafactory.tf - The terraform configuration for creation of GCP DataFactory resources
        - gcp-keyvault.tf - The terraform configuration for creation of GCP key vault resources
        - gcp-storageaccount.tf - The terraform configuration for creation of GCP storage account resources
    - keyvault.tf - The terraform configuration for creation of Key Vault
    - applicationinsights.tf - The terraform configuration for creation of Application Insights  account for DMP
    - datafactory.tf - The terraform configuration for creation of Data Factory
    - eventgrid.tf - The terraform configuration for creation of Event Grid
    - eventhub.tf - The terraform configuration for creation of EventHub Namespace and EventHub
    - outputs.tf - All Terraform outputs are configured in this file
    - servicebus.tf - The terraform configuration for creation of Service Bus
    - serviceplantnapp.tf - The terraform configuration for creation of Service plan, storage account and function apps
    - sqlserver.tf - The terraform configuration for creation of SQL server and databases
    - variables.tf - This file contains all the variables used in the terraform , overridden by the environment specific tfvar files
    - versions.tf - This file describes the terraform and provider versions necessary to run the Terraform
    - virtualmachine.tf - The terraform configuration for creation of Virtual machines
    - compound-metric-monitoring-dashboard.tf - The terraform configuration for creation of Compound Metric Monitoring Dashboard
    - compound-log-analytics-monitoring-dashboard.tf - The terraform configuration for creation of Compound Log Analytics Monitoring Dashboard
    - alert_script_all.tf - The terraform configuration for creation of Alert rules in dmp
    - loganalyticsworkspace.tf - The terraform configuration for creation of Log Analytics Workspace
    - la_dmp_resource_health_monitor.tf - The terraform configuration to run arm template for logic app
    
- .gitignore - defines the files and folders ignored by git.

# Usage

See [Contributing.md](/docs/CONTRIBUTING.md) for instructions on how to set up and contribute to this repo.

# Terraform

## Requirements

| Name | Version |
|------|---------|
| terraform | = 0.13.2 |
| azurerm | 2.26.0 |
| random | 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 2.26.0 |
| null | n/a |
| random | 2.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment\_name | n/a | `any` | n/a | yes |
| subscription | n/a | `any` | n/a | yes |
| subscription\_id | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| app\_id | n/a |
