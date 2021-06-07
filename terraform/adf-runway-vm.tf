# Virtual machines for ADF

resource "azurerm_virtual_machine" "runway_ingestion_adf_vm" {
  count                 = length(local.env.runway_adf_vm_name)
  name                  = local.env.runway_adf_vm_name[count.index]
  location              = local.env.location
  resource_group_name   = local.env.ingest_resource_group_name
  network_interface_ids = [azurerm_network_interface.runway_ingestion_adf_nic[count.index].id]
  vm_size               = local.env.runway_adf_vm_size
  depends_on            = [azurerm_key_vault_secret.runway_ingestion_vm_pass_secret]

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = local.env.runway_adf_vm_os_disk_name[count.index]
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.env.runway_adf_vm_name[count.index]
    admin_username = local.env.runway_adf_vm_admin_username
    admin_password = azurerm_key_vault_secret.runway_ingestion_vm_pass_secret[count.index].value

    custom_data = filebase64("../scripts/${local.env.runway_adf_ir_vm_install_script_name}")
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  tags = {
    application-name = local.env.tag_application_name
    cost-center      = local.env.tag_cost_center
    owner            = local.env.tag_owner
    spm-id           = local.env.tag_spm_id
    lob              = local.env.tag_lob
  }
}


# The script to install the Integration Runtime is added to the virtual machine via:
# azurerm_virtual_machine.runway_ingestion_adf_vm.os_profile.custom_data = filebase64("../scripts/${local.env.runway_adf_ir_vm_install_script_name}")
# it is added to the %SYSTEMDRIVE%\\AzureData folder as CustomData.bin
# https://docs.microsoft.com/en-us/azure/virtual-machines/custom-data#windows
# This azurerm_virtual_machine_extension renames the file to Install-IntegrationRuntime.ps1 and runs it
resource "azurerm_virtual_machine_extension" "runway_ingestion_adf_vm_ext_ir_install" {
  count                = length(azurerm_virtual_machine.runway_ingestion_adf_vm)
  name                 = "${azurerm_virtual_machine.runway_ingestion_adf_vm[count.index].name}-EXT"
  virtual_machine_id   = azurerm_virtual_machine.runway_ingestion_adf_vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
    {
        "commandToExecute": "ren %SYSTEMDRIVE%\\AzureData\\CustomData.bin Install-IntegrationRuntime.ps1 & powershell.exe -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -File %SYSTEMDRIVE%\\AzureData\\Install-IntegrationRuntime.ps1 ${azurerm_data_factory_integration_runtime_self_hosted.runway_ingestion_shared_adf_ir_self_hosted.auth_key_1}"
    }
    SETTINGS
}

# Creating network interface for the Virtual Machine
resource "azurerm_network_interface" "runway_ingestion_adf_nic" {
  count               = length(local.env.runway_adf_vm_nic_name)
  name                = local.env.runway_adf_vm_nic_name[count.index]
  location            = local.env.location
  resource_group_name = local.env.ingest_resource_group_name

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     = local.env.runway_adf_vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Generating random password for Azure VM
resource "random_password" "runway_ingestion_vm_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# store the random password in keyvault
resource "azurerm_key_vault_secret" "runway_ingestion_vm_pass_secret" {
  count        = length(local.env.runway_adf_vm_name)
  name         = local.env.runway_adf_vm_name[count.index]
  value        = random_password.runway_ingestion_vm_password.result
  key_vault_id = azurerm_key_vault.runway_ingestion_key_vault.id
  content_type = "VM-Password"
  depends_on   = [azurerm_key_vault_access_policy.runway_ingestion_service_principal_keyvault_policy]
}
