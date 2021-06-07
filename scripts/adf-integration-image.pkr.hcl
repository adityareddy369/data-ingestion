variable "CLIENT_ID" {}
variable "CLIENT_SECRET" {}
variable "SUBSCRIPTION_ID" {}
variable "TENANT_ID" {}

variable "vnet_name" {}
variable "subnet_name" {}

variable "vault_id" {}

source "azure-arm" "basic-example" {
  client_id = var.CLIENT_ID
  client_secret = var.CLIENT_SECRET
  subscription_id = var.SUBSCRIPTION_ID
  tenant_id = var.TENANT_ID

  os_type = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer = "WindowsServer"
  image_sku = "2019-Datacenter"

  vm_size = "Standard_D2_v3"
  communicator = "winrm"
  winrm_use_ssl = "true"
  winrm_insecure = "true"
  winrm_timeout = "5m"

  virtual_network_name = var.vnet_name
  virtual_network_subnet_name = var.subnet_name
  virtual_network_resource_group_name = "networking-eastus2"
  
  build_resource_group_name = "networking-eastus2"
  build_key_vault_name = var.vault_id

  managed_image_name = "adf-ir-image"
  managed_image_resource_group_name = "networking-eastus2"
}

build {
  sources = [
    "sources.azure-arm.basic-example"
  ]

  provisioner "powershell" {
    script = "./ConfigureRemotingForAnsible.ps1"
  }

  provisioner "ansible" {
    playbook_file = "./install-integration-runtime-playbook.yml"
    user = "packer"
    use_proxy = false
    extra_arguments = [
      "-e", "ansible_winrm_server_cert_validation=ignore"
    ]
  }
}