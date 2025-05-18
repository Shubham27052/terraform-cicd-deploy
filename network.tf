
resource "azurerm_resource_group" "resourceGroup" {
  location = "eastus"
  name     = "devrg_tf2"

}

resource "azurerm_virtual_network" "main_vnet" {
  address_space                  = ["192.168.30.0/24"]
  bgp_community                  = null
  dns_servers                    = []
  edge_zone                      = null
  location                       = "eastus"
  name                           = "tsptkd-vnet-prd-ue-01"
  private_endpoint_vnet_policies = "Disabled"
  resource_group_name            = azurerm_resource_group.resourceGroup.name

}


resource "azurerm_subnet" "gateway_subnet" {
  address_prefixes                              = ["192.168.30.64/26"]
  default_outbound_access_enabled               = false
  name                                          = "GatewaySubnet"
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.resourceGroup.name
  service_endpoint_policy_ids                   = []
  service_endpoints                             = []
  virtual_network_name                          = azurerm_virtual_network.main_vnet.name
}

resource "azurerm_subnet" "appgw_subnet" {
  address_prefixes                              = ["192.168.30.0/26"]
  default_outbound_access_enabled               = false
  name                                          = "tsptkd-snet-prd-appgw-ue-01"
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.resourceGroup.name
  service_endpoint_policy_ids                   = []
  service_endpoints                             = []
  virtual_network_name                          = azurerm_virtual_network.main_vnet.name
}

resource "azurerm_subnet" "db_subnet" {
  address_prefixes                              = ["192.168.30.160/27"]
  default_outbound_access_enabled               = true
  name                                          = "tsptkd-snet-prd-db-ue-01"
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.resourceGroup.name
  service_endpoint_policy_ids                   = []
  service_endpoints                             = []
  virtual_network_name                          = azurerm_virtual_network.main_vnet.name
}

resource "azurerm_subnet" "app_subnet" {
  address_prefixes                              = ["192.168.30.128/27"]
  default_outbound_access_enabled               = true
  name                                          = "tsptkd-snet-prd-app-ue-01"
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.resourceGroup.name
  service_endpoint_policy_ids                   = []
  service_endpoints                             = []
  virtual_network_name                          = azurerm_virtual_network.main_vnet.name
}

