resource "azurerm_network_interface" "app_vm_nic" {
  accelerated_networking_enabled = false

  ip_forwarding_enabled = false
  location              = "eastus"
  name                  = "tsptkd-nic-prd-app-ue-02"
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  tags                  = {}
  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address            = "192.168.30.133"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    subnet_id                     = azurerm_subnet.app_subnet.id
  }
}

resource "azurerm_network_interface_security_group_association" "app_vm_nicnsg_association" {
  network_interface_id      = azurerm_network_interface.app_vm_nic.id
  network_security_group_id = azurerm_network_security_group.app_vm_nsg.id
  depends_on = [
    azurerm_network_interface.app_vm_nic,
  ]
}

resource "azurerm_network_security_group" "app_vm_nsg" {
  location            = "eastus"
  name                = "tsptkd-nsg-prd-app-ue-01"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  security_rule = [{
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "443"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "AllowAnyHTTPSInbound"
    priority                                   = 100
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }]
  tags = {}
}


resource "azurerm_managed_disk" "app_vm_datadisk" {
  create_option                     = "Empty"
  disk_size_gb                      = 128
  location                          = "eastus"
  name                              = "vmctefe01p-datadisk01"
  on_demand_bursting_enabled        = false
  optimized_frequent_attach_enabled = false
  os_type                           = null
  performance_plus_enabled          = false
  public_network_access_enabled     = true
  resource_group_name               = azurerm_resource_group.resourceGroup.name

  storage_account_type = "StandardSSD_LRS"
  tags                 = {}

  trusted_launch_enabled = false

}

resource "azurerm_windows_virtual_machine" "app_vm" {
  admin_password                                         = var.vm_password
  admin_username                                         = var.vm_username
  allow_extension_operations                             = true
  availability_set_id                                    = null
  bypass_platform_safety_checks_on_user_schedule_enabled = false
  capacity_reservation_group_id                          = null
  computer_name                                          = "vmctefe01p"

  disk_controller_type = "SCSI"

  enable_automatic_updates   = false
  encryption_at_host_enabled = false

  extensions_time_budget = "PT1H30M"
  hotpatching_enabled    = false

  location      = "eastus"
  max_bid_price = -1
  name          = "vmctefe01p"
  network_interface_ids = [azurerm_network_interface.app_vm_nic.id]

  patch_assessment_mode = "ImageDefault"
  patch_mode            = "Manual"
  priority              = "Regular"
  provision_vm_agent    = true
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  secure_boot_enabled   = false
  size                  = var.app_vm_size

  boot_diagnostics {
    storage_account_uri = null
  }
  os_disk {
    caching                   = "ReadWrite"
    disk_size_gb              = 128
    name                      = "vmctefe01p-osdisk"
    storage_account_type      = "StandardSSD_LRS"
    write_accelerator_enabled = false
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-Datacenter-g2"
    version   = "latest"
  }
}



resource "azurerm_virtual_machine_extension" "app_vm_ext_enablevmAccess" {
  auto_upgrade_minor_version  = true
  automatic_upgrade_enabled   = false
  failure_suppression_enabled = false
  name                        = "enablevmAccess"
  protected_settings          = null # sensitive
  provision_after_extensions  = []
  publisher                   = "Microsoft.Compute"
  settings = jsonencode({
    userName = "tkdadmin"
    password = "3PDQP11iB46V"
  })
  tags                 = {}
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  # virtual_machine_id   = "/subscriptions/f73a7f0f-eca9-48e7-8ff8-3050c11c67f2/resourceGroups/tsptkd-rg-prd-tkd-ue-01/providers/Microsoft.Compute/virtualMachines/vmctefe01p"
  virtual_machine_id = azurerm_windows_virtual_machine.app_vm.id
}

resource "azurerm_virtual_machine_extension" "app_vm_ext_AzureNetworkWatcherExtension" {
  auto_upgrade_minor_version  = true
  automatic_upgrade_enabled   = false
  failure_suppression_enabled = false
  name                        = "AzureNetworkWatcherExtension"
  protected_settings          = null # sensitive
  provision_after_extensions  = []
  publisher                   = "Microsoft.Azure.NetworkWatcher"
  settings                    = jsonencode({})
  tags                        = {}
  type                        = "NetworkWatcherAgentWindows"
  type_handler_version        = "1.4"
  # virtual_machine_id          = "/subscriptions/f73a7f0f-eca9-48e7-8ff8-3050c11c67f2/resourceGroups/tsptkd-rg-prd-tkd-ue-01/providers/Microsoft.Compute/virtualMachines/vmctefe01p"
  virtual_machine_id = azurerm_windows_virtual_machine.app_vm.id

}
