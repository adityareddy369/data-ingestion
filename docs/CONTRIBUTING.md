# Contributing

This document provides guidelines for contributing to the repository.

## Dependencies

The following dependencies must be installed on the development system:

- [Terraform][https://www.terraform.io/downloads.html] v12.x
- [Visual Studio Code](https://code.visualstudio.com/) or your IDE of choice
- [Git](https://git-scm.com/download/win)


## Terraform variables

Variables can be injected into the Terraform pipeline tasks using `TF_VAR_` syntax in the `TerraformEnvVariables` parameter as [described in the documentation](https://www.terraform.io/docs/commands/environment-variables.html#tf_var_name).

## Secrets management

### Generate secrets with Terraform using random password

To demonstrate one approach to secrets management, the Terraform configuration generates a random password (per stage) for the SQL Server 1 instance, stored in Terraform state. You can adapt this to suit your lifecycle.

## Getting started

How to use Azure DevOps for provisioning resources using terraform

## Azure DevOps pipeline

Create a Service Connection of type Azure Resource Manager at subscription scope. Name the Service Connection `Terraform`.
Allow all pipelines to use the connection.

In `https://github.com/krogertechnology/dmp-enterprise-data-ingestion/master/azure-pipelines.yml`, update the `TerraformBackendStorageAccount` name to a globally unique storage account name.
The pipeline will create the storage account.

Create a build pipeline.

## Usage on non-master branch

To avoid issues with concurrent access to the Terraform state file, the jobs running Terraform `plan` and `apply` commands
run by default only on the `master` branch. On other branches, they are skipped by default:

You can set the `RUN_FLAG_TERRAFORM` variable (to any non-empty value)
when running the pipeline, to trigger Terraform application on a non-`master` branch.

## Generating Documentation for Inputs and Outputs

The Inputs and Outputs tables in the READMEs of the root module, submodules, and example modules are generated based on the variables and outputs of the respective modules via [terraform-docs](https://github.com/terraform-docs/terraform-docs). These tables must be refreshed if the module interfaces are changed.

## Linting and Formatting

Before submitting a PR request
- perform a [terraform fmt](https://www.terraform.io/docs/commands/fmt.html).
- Update the Contents section of the docs/README.md
- Ensure you are following the Pull Request guidelines documented in the docs/PULL_REQUEST_TEMPLATE.md