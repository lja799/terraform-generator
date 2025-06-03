resource "azurerm_network_security_rule" "agw_rule" {
  for_each = { for location in local.nsg_locations : location => location }

  name                         = "agw-rule"
  priority                     = 500
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_address_prefixes      = local.ipam.zones.zone1
  source_port_range            = "*"
  destination_address_prefixes = concat(local.ipam.networks.test-uat.appgw)
  destination_port_ranges      = concat([local.ports.http, local.ports.https])
  resource_group_name          = "network"
  network_security_group_name  = "uat-australiaeast-infrastructure"
}

resource "azurerm_network_security_rule" "management_uat" {
  name      = "Management-${title(uat)}"
  priority  = 501
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"
  source_address_prefixes = concat(
    [local.ipam.hosts.node_n001]
  )
  source_port_range            = "*"
  destination_address_prefixes = local.ipam.networks.uat.nodes
  destination_port_ranges      = concat([local.ports.https, local.ports.http])
  resource_group_name          = "network"
  network_security_group_name  = "uat-australiaeast-infrastructure"
}

resource "azurerm_network_security_rule" "staff_to_storage_file" {
  for_each = { for location in local.nsg_locations : location => location }

  name                         = "Frontend-Access-to-storage-file"
  priority                     = 502
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_address_prefixes      = concat(local.ipam.zones.zone1, [local.ipam.hosts.host1], [local.ipam.hosts.host2])
  source_port_range            = "*"
  destination_address_prefixes = concat(local.ipam.networks.uat.storage-file-ip)
  destination_port_ranges      = concat([local.ports.https, local.ports.smb])
  resource_group_name          = "network"
  network_security_group_name  = "uat-australiaeast-infrastructure"
}
