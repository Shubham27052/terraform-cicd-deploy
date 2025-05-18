resource "azurerm_network_interface" "db_vm_nic" {
  accelerated_networking_enabled = false
  ip_forwarding_enabled          = false
  location                       = "eastus"
  name                           = "tsptkd-nic-prd-db-ue-02"
  resource_group_name            = azurerm_resource_group.resourceGroup.name
  tags                           = {}
  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address            = "192.168.30.165"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    subnet_id                     = azurerm_subnet.db_subnet.id
  }
}

resource "azurerm_network_security_group" "db_vm_nsg" {
  location            = "eastus"
  name                = "tsptkd-nsg-prd-db-ue-01"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  security_rule       = []
  tags                = {}
}


resource "azurerm_network_interface_security_group_association" "db_vm_nicnsg_association" {
  network_interface_id      = azurerm_network_interface.db_vm_nic.id
  network_security_group_id = azurerm_network_security_group.db_vm_nsg.id
  depends_on = [
    azurerm_network_interface.db_vm_nic,
  ]
}





resource "azurerm_windows_virtual_machine" "db_vm" {
  admin_password                                         = var.vm_password
  admin_username                                         = var.vm_username
  allow_extension_operations                             = true
  bypass_platform_safety_checks_on_user_schedule_enabled = false
  computer_name                                          = "vmctedb01p"
  disk_controller_type                                   = "SCSI"
  enable_automatic_updates                               = false
  encryption_at_host_enabled                             = false

  extensions_time_budget = "PT1H30M"
  hotpatching_enabled    = false
  location               = "eastus"
  name                   = "vmctedb01p"
  network_interface_ids  = [azurerm_network_interface.db_vm_nic.id]
  patch_assessment_mode  = "ImageDefault"
  patch_mode             = "Manual"
  priority               = "Regular"
  provision_vm_agent     = true
  resource_group_name    = azurerm_resource_group.resourceGroup.name
  secure_boot_enabled    = false
  size                   = var.db_vm_size

  tags = {
    "Application Domain" = "trakaid"
    "Application Name"   = "Cylotrak(CTE)"
    "Application Owners" = "Dr.Dhiresh Vyas, Gangadhar Pasupula"
    Environment          = "Production"
  }

  vm_agent_platform_updates_enabled = false
  vtpm_enabled                      = false

  boot_diagnostics {
    storage_account_uri = null
  }
  os_disk {
    caching                = "ReadWrite"
    disk_encryption_set_id = null
    disk_size_gb           = 128
    name                   = "vmctedb01p-osdisk"

    storage_account_type      = "StandardSSD_LRS"
    write_accelerator_enabled = false
  }
  source_image_reference {
    offer     = "SQL2022-WS2022"
    publisher = "MicrosoftSQLServer"
    sku       = "standard-gen2"
    version   = "latest"
  }
}

resource "azurerm_mssql_virtual_machine" "virtualmachine_sqlvm" {
  virtual_machine_id               = azurerm_windows_virtual_machine.db_vm.id
  sql_license_type                 = "PAYG"
  sql_connectivity_update_username = var.db_username
  sql_connectivity_update_password = var.db_password
}


resource "azurerm_managed_disk" "db_vm_datadisk" {
  create_option                     = "Empty"
  disk_size_gb                      = 128
  location                          = "eastus"
  name                              = "vmctedb01p-datadisk01"
  network_access_policy             = null
  on_demand_bursting_enabled        = false
  optimized_frequent_attach_enabled = false
  os_type                           = null
  performance_plus_enabled          = false
  public_network_access_enabled     = true
  resource_group_name               = azurerm_resource_group.resourceGroup.name

  storage_account_type   = "StandardSSD_LRS"
  tags                   = {}
  tier                   = null
  trusted_launch_enabled = false


}

resource "azurerm_virtual_machine_extension" "db_vm_ext_AzureNetworkWatcherExtension" {
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
  virtual_machine_id          = azurerm_windows_virtual_machine.db_vm.id
}

resource "azurerm_virtual_machine_extension" "db_vm_ext_AzureBackupWindowsWorkload" {
  auto_upgrade_minor_version  = false
  automatic_upgrade_enabled   = false
  failure_suppression_enabled = false
  name                        = "AzureBackupWindowsWorkload"
  protected_settings          = null # sensitive
  provision_after_extensions  = []
  publisher                   = "Microsoft.Azure.RecoveryServices.WorkloadBackup"
  settings = jsonencode({
    commandStartTimeUTCTicks = "638803923461896194"
    locale                   = "en-us"
    objectStr                = "eyJXb3JrbG9hZFR5cGVzTGlzdCI6WyJTUUwiXSwiY29udGFpbmVyUHJvcGVydGllcyI6eyJDb250YWluZXJJRCI6Ilwvc3Vic2NyaXB0aW9uc1wvZjczYTdmMGYtZWNhOS00OGU3LThmZjgtMzA1MGMxMWM2N2YyXC9yZXNvdXJjZUdyb3Vwc1wvdHNwdGtkLXJnLXByZC10a2QtdWUtMDFcL3Byb3ZpZGVyc1wvTWljcm9zb2Z0LkNvbXB1dGVcL3ZpcnR1YWxNYWNoaW5lc1wvdm1jdGVkYjAxcCIsIklkTWdtdENvbnRhaW5lcklkIjozOTgwNTI4LCJQcm92aWRlclR5cGUiOiJBenVyZVdvcmtsb2FkIiwiUmVzb3VyY2VJZCI6Ijg5NTUxNjMxNDcwNDYwNDc3MTYiLCJTdWJzY3JpcHRpb25JZCI6ImY3M2E3ZjBmLWVjYTktNDhlNy04ZmY4LTMwNTBjMTFjNjdmMiIsIlVuaXF1ZUNvbnRhaW5lck5hbWUiOiJDb21wdXRlO3RzcHRrZC1yZy1wcmQtdGtkLXVlLTAxO3ZtY3RlZGIwMXAiLCJWYXVsdFByaXZhdGVFbmRwb2ludFN0YXRlIjoiTm9uZSJ9LCJyZWdpc3RyYXRpb25UeXBlIjoiUmVnaXN0cmF0aW9uIiwic3RhbXBMaXN0IjpbeyJTZXJ2aWNlTmFtZSI6NSwiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLXdiY20xLmV1cy5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjMsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1tb24xLmV1cy5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjYsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1wcm90MWkuZXVzLmJhY2t1cC53aW5kb3dzYXp1cmUuY29tIn0seyJTZXJ2aWNlTmFtZSI6MSwiU2VydmljZVN0YW1wVXJsIjoiaHR0cHM6XC9cL3BvZDAxLWlkMS5ldXMuYmFja3VwLndpbmRvd3NhenVyZS5jb20ifSx7IlNlcnZpY2VOYW1lIjo0LCJTZXJ2aWNlU3RhbXBVcmwiOiJodHRwczpcL1wvcG9kMDEtZWNzMS5ldXMuYmFja3VwLndpbmRvd3NhenVyZS5jb20ifSx7IlNlcnZpY2VOYW1lIjoyLCJTZXJ2aWNlU3RhbXBVcmwiOiJodHRwczpcL1wvcG9kMDEtbWFuYWcxLmV1cy5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjcsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS1mYWIxLmV1cy5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9LHsiU2VydmljZU5hbWUiOjgsIlNlcnZpY2VTdGFtcFVybCI6Imh0dHBzOlwvXC9wb2QwMS10ZWwxLmV1cy5iYWNrdXAud2luZG93c2F6dXJlLmNvbSJ9XX0="
    taskId                   = "58305fed-6bc6-45d1-81df-ae8e26e02a7f"
    triggerForceUpgrade      = false
    vmType                   = "microsoft.compute/virtualmachines"
  })
  tags                 = {}
  type                 = "AzureBackupWindowsWorkload"
  type_handler_version = "1.1"
  virtual_machine_id   = azurerm_windows_virtual_machine.db_vm.id
}

resource "azurerm_virtual_machine_extension" "db_vm_ext_enablevmAccess" {
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
  virtual_machine_id   = azurerm_windows_virtual_machine.db_vm.id
}

resource "azurerm_virtual_machine_extension" "db_vm_ext_SqlIaasExtension" {
  auto_upgrade_minor_version  = true
  automatic_upgrade_enabled   = true
  failure_suppression_enabled = false
  name                        = "SqlIaasExtension"
  protected_settings          = null # sensitive
  provision_after_extensions  = []
  publisher                   = "Microsoft.SqlServer.Management"
  settings = jsonencode({
    DeploymentTokenSettings = {
      DeploymentToken = "6372792"
    }
    ServerConfigurationsManagementSettings = {
      AdditionalFeaturesServerConfigurations = {
        BackupPermissionsForAzureBackupSvc = true
      }
    }
  })
  tags                 = {}
  type                 = "SqlIaaSAgent"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_windows_virtual_machine.db_vm.id
}

