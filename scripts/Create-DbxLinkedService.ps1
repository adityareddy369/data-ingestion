<#
  .SYNOPSIS
    This script Creates the DataBricks Linked Service for Azure DataFactory
  .DESCRIPTION
    This PowerShell script does the following:
    - Installs the required modules
      - Az
      - az.DataFactory
    - Checks if the DataBricks Linked Service exists
    - If not, 
      - Generates a DataBricks token for the deployment Service Principal
      - Retrieves the InstancePoolId for the Databricks pool
      - Builds the JSON template for the DataBricks Linked Service
      - Creates the DataBricks Linked Service

  .Notes
    This script is run from a Terraform Local_Exec Resource.

    The DMP nonprod Databricks workspace is shared amongst the build, dev, and test environments.  
    Thus this script requires additional paramters for DbxWorkspaceName, DbxInsanceUrl, and DbxInstancePoolName
      because some environments may share those resources or have different naming conventions
    
    This script is not idempotent.  If a configuration value changes such as newClusterNumOfWorker, 
      newClusterSparkEnvVars, or newClusterVersion, the script will not change the existing Linked 
      Service values.  An attempt was made to make the script idempotent however, the properties exposed 
      from Get-AzDataFactoryV2LinkedService are very difficult to iterate.  
      This should be improved in the future.

    # Parameters:
      - Environment:  dev, test, prod, stage
      - AdfResourceGroupName: Resource Group Name containing Azure DataFactory
      - DataFactoryName: Name of Azure Data Factory
      - IntegrationRuntimeName: Name of Integration Runtime within Azure Data Factory
      - DbxResourceGroupName: Resource Group Name containing Azure DataBricks
      - DbxInsanceUrl: URL of Azure DataBricks instance 
      - DbxWorkspaceName:  Azure DataBricks Workspace Name
      - DbxInstancePoolName:  Environment specific Azure DataBricks Instance Pool
      - DbxSecretScopeName:  Environment specific Azure DataBricks Secret Scope Name
      - dbxLsName: Name of Azure DataFactory Linked Service for Azure DataBricks
      - DbxLinkedServiceId: (sazDMP-ETL-Raw-Writer) Id of the App Registration to communicate with ADLS Gen2
      
#>
param (
  [Parameter(Mandatory=$true)]
    [string]$Environment,
  [Parameter(Mandatory=$true)]
    [string]$AdfResourceGroupName,
  [Parameter(Mandatory=$true)]
    [string]$DataFactoryName,
  [Parameter(Mandatory=$true)]
    [string]$IntegrationRuntimeName,
  [Parameter(Mandatory=$true)]
    [string]$DbxResourceGroupName,
  [Parameter(Mandatory=$true)]
    [string]$DbxInsanceUrl,
  [Parameter(Mandatory=$true)]
    [string]$DbxWorkspaceName,
  [Parameter(Mandatory=$true)]
    [string]$DbxInstancePoolName,
    [Parameter(Mandatory=$true)]
    [string]$DbxSecretScopeName,
  [Parameter(Mandatory=$false)]
    [string]$dbxLsName="lsDataBricks",
  [Parameter(Mandatory=$true)]
    [string]$DbxLinkedServiceId
)

###################### Connect to Azure and install Modules ######################
$subscriptionId = $env:ARM_SUBSCRIPTION_ID
$tenantId = $env:ARM_TENANT_ID
$clientId = $env:ARM_CLIENT_ID
$secret = $env:ARM_CLIENT_SECRET

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name Az -AllowClobber
Install-Module az.DataFactory

# Need to connect separately as this script is run from Terraform as a Local_Exec resource instead of an Azure CLI or PowerShell task
$securesecret = ConvertTo-SecureString -String $secret -AsPlainText -Force
$Credential = New-Object pscredential($clientId,$securesecret)
Connect-AzAccount -Credential $Credential -Tenant $tenantId -ServicePrincipal
Select-AzSubscription $subscriptionId
###################### End Connect to Azure and install Modules ######################

###################### Create dbx Linked Service ######################
try {
  Write-Host "Getting $dbxLsName Linked Service"
  $dbxls = Get-AzDataFactoryV2LinkedService -ResourceGroupName $AdfResourceGroupName -DataFactoryName $DataFactoryName -Name $dbxLsName -ErrorAction Stop #ErrorAction is specifically set here as Get-AzDataFactoryV2LinkedService returns a non-terminating error if the Linked Service exists 
  Write-Host "$dbxLsName exists. Exiting"
} catch {

  Write-Host "Linked Service: $dbxLsName Not Found, Creating"

  ####### Connect to DataBricks REST API via Service Principal
  Write-Host "Connecting to DataBricks via Deployment Service Principal"
  $DataBricksAuthApiData = "grant_type=client_credentials&client_id=$clientId&resource=2ff814a6-3304-4ab8-85cb-cd0e6f879c1d&client_secret=$secret"

  Write-Host "Getting DataBricks API token"
  $DataBricksAuthApiToken = $(Invoke-RestMethod -Method 'Get' -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $DataBricksAuthApiData | Select-Object -Property access_token).access_token

  Write-Host "Getting AzureRM Management API token"
  $AzureRmManagementAuthApiData = "grant_type=client_credentials&client_id=$clientId&resource=https://management.core.windows.net/&client_secret=$secret"
  $AzureRmManagementAuthApiToken = $(Invoke-RestMethod -Method 'Get' -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $AzureRmManagementAuthApiData | Select-Object -Property access_token).access_token

  write-host "DBX API request: $DbxInsanceUrl/api/2.0/instance-pools/get"
  write-host "DBX Workspace: $DbxWorkspaceName"
  write-host "DBX resource Group: $DbxResourceGroupName"

  $DataBricksTokenHeaders = @{
    "Authorization" = "Bearer $DataBricksAuthApiToken"
    "X-Databricks-Azure-SP-Management-Token" = "$AzureRmManagementAuthApiToken"
    "X-Databricks-Azure-Workspace-Resource-Id" = "/subscriptions/$subscriptionId/resourceGroups/$DbxResourceGroupName/providers/Microsoft.Databricks/workspaces/$DbxWorkspaceName"
  }

  Write-Host "Getting DataBricks instance_pools."
  $InstancePools = Invoke-RestMethod -Method 'Get' -Uri "$DbxInsanceUrl/api/2.0/instance-pools/list" -Headers $DataBricksTokenHeaders
  $InstancePoolId = $($InstancePools.instance_pools | Where-Object {$_.instance_pool_name -eq $DbxInstancePoolName} | Select-Object -Property instance_pool_id).instance_pool_id

  Write-Host "Instance Pool ID:   $InstancePoolId"

  ####### Generate JSON file
  # This JSON was generated by manually creating a dbx linked service and then going to the properties of that linked service to copy the JSON.

  # Hotfix Add reference for Hive Metastore Database to newClusterSparkConf
  # This should be changed to import a reference for the store at an earlier stage in the pipeline

$dbxLsJsonString = @"
{
  "name": "$dbxLsName",
  "properties": {
    "annotations": [],
    "type": "AzureDatabricks",
    "typeProperties": {
      "domain": "$DbxInsanceUrl",
      "authentication": "MSI",
      "workspaceResourceId": "/subscriptions/$subscriptionId/resourceGroups/$DbxResourceGroupName/providers/Microsoft.Databricks/workspaces/$DbxWorkspaceName",
      "instancePoolId": "$InstancePoolId",
      "newClusterNumOfWorker": "4:64",
      "newClusterSparkConf" : {
        "spark.hadoop.javax.jdo.option.ConnectionDriverName": "com.microsoft.sqlserver.jdbc.SQLServerDriver",
        "spark.hadoop.javax.jdo.option.ConnectionURL": "jdbc:sqlserver://dmp-sql-metastore-$Environment-001.database.windows.net:1433;database=DMP_Hive_Metastore",
        "spark.hadoop.javax.jdo.option.ConnectionUserName": "dmprunwaymetastoreadmin",
        "spark.hadoop.javax.jdo.option.ConnectionPassword": "{{secrets/$DbxSecretScopeName/AZURE-SQL-SERVER-HIVE-METASTORE-PASSWORD}}",
        "spark.hadoop.datanucleus.autoCreateSchema": "true",
        "spark.sql.hive.metastore.version": "0.13",
        "spark.hadoop.datanucleus.fixedDataStore": "false",
        "spark.databricks.delta.preview.enabled": "true",
        "spark.sql.hive.metastore": "maven",
		    "fs.azure.account.oauth.provider.type.dmpdatalake$Environment.dfs.core.windows.net": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
		    "fs.azure.account.auth.type.dmpdatalake$Environment.dfs.core.windows.net": "OAuth",
		    "fs.azure.account.oauth2.client.secret.dmpdatalake$Environment.dfs.core.windows.net": "{{secrets/$DbxSecretScopeName/svc-5839-runway-datalake-unrestricted-writer-password}}",
		    "fs.azure.account.oauth2.client.endpoint.dmpdatalake$Environment.dfs.core.windows.net": "https://login.microsoftonline.com/8331e14a-9134-4288-bf5a-5e2c8412f074/oauth2/token",
		    "fs.azure.account.oauth2.client.id.dmpdatalake$Environment.dfs.core.windows.net": "{{secrets/$DbxSecretScopeName/svc-5839-runway-datalake-unrestricted-writer-client-id}}"

      },
      "newClusterSparkEnvVars": {
        "LOG_ANALYTICS_WORKSPACE_ID": "{{secrets/$DbxSecretScopeName/log-analytics-workspace-id}}",
        "LOG_ANALYTICS_WORKSPACE_KEY": "{{secrets/$DbxSecretScopeName/log-analytics-workspace-key}}",
        "PYSPARK_PYTHON": "/databricks/python3/bin/python3"
      },
      "newClusterVersion": "7.3.x-scala2.12",
      "newClusterInitScripts": [
        "dbfs:/databricks/spark-monitoring/spark-monitoring.sh"
      ]
    },
    "connectVia": {
      "referenceName": "$IntegrationRuntimeName",
      "type": "IntegrationRuntimeReference"
    },
    "connectVia": {
      "referenceName": "dmp-adf-runway-shr-eastus2-$Environment-001",
      "type": "IntegrationRuntimeReference"
  }
  }
}
"@

  $dbxLsJsonString | Out-File -FilePath .\dbxLs.json

  try {
    #Create or update the dbx Linked Service.  confirm:$false set in case the linked service exists.
    Set-AzDataFactoryV2LinkedService -ResourceGroupName $AdfResourceGroupName -DataFactoryName $DataFactoryName -Name $dbxLsName -File ".\\dbxLs.json" -confirm:$False -Force -ErrorAction Stop
    Write-Host "Created DataBricks Linked Service $dbxLsName"
  } catch [Exception] {
    Write-Host "Error creating or updated linked service.  Exiting."
    Write-Host $_.Exception.GetType().FullName
    Write-Host $_.Exception.Message
    exit 1
  }
}
###################### End Create dbx Linked Service ######################