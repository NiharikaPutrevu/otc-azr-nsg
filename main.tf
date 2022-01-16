data "azurerm_resource_group" "vnet" {
  name = var.resource_group_name
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-nsg"
  location            = coalesce(var.location, data.azurerm_resource_group.vnet.location)
  resource_group_name = data.azurerm_resource_group.vnet.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "nsg" {
  count = length(var.rules)

  name                                       = lookup(var.rules[count.index], "name")
  priority                                   = lookup(var.rules[count.index], "priority")
  direction                                  = lookup(var.rules[count.index], "direction", "Any")
  access                                     = lookup(var.rules[count.index], "access", "Allow")
  protocol                                   = lookup(var.rules[count.index], "protocol", "*")
  source_port_range                          = lookup(var.rules[count.index], "source_port_range", null) == null ? "*" : null
  source_port_ranges                         = lookup(var.rules[count.index], "source_port_range", null) == null ? null : split(",", replace(lookup(var.rules[count.index], "source_port_range", "*"), "*", "0-65535"))
  destination_port_range                     = lookup(var.rules[count.index], "destination_port_range", null) == null ? "*" : null
  destination_port_ranges                    = lookup(var.rules[count.index], "destination_port_range", null) == null ? null : split(",", replace(lookup(var.rules[count.index], "destination_port_range", "*"), "*", "0-65535"))
  source_address_prefix                      = lookup(var.rules[count.index], "source_application_security_group_ids", null) == null && lookup(var.rules[count.index], "source_address_prefixes", null) == null ? lookup(var.rules[count.index], "source_address_prefix", "*") : null
  source_address_prefixes                    = lookup(var.rules[count.index], "source_application_security_group_ids", null) == null ? lookup(var.rules[count.index], "source_address_prefixes", null) : null
  destination_address_prefix                 = lookup(var.rules[count.index], "destination_application_security_group_ids", null) == null && lookup(var.rules[count.index], "destination_address_prefixes", null) == null ? lookup(var.rules[count.index], "destination_address_prefix", "*") : null
  destination_address_prefixes               = lookup(var.rules[count.index], "destination_application_security_group_ids", null) == null ? lookup(var.rules[count.index], "destination_address_prefixes", null) : null
  description                                = lookup(var.rules[count.index], "description", "Security rule for ${lookup(var.rules[count.index], "name", "default_rule_name")}")
  resource_group_name                        = data.azurerm_resource_group.vnet.name
  network_security_group_name                = azurerm_network_security_group.nsg.name
  source_application_security_group_ids      = lookup(var.rules[count.index], "source_application_security_group_ids", null)
  destination_application_security_group_ids = lookup(var.rules[count.index], "destination_application_security_group_ids", null)
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  count = length(var.subnet_ids)

  subnet_id                 = var.subnet_ids[count.index]
  network_security_group_id = azurerm_network_security_group.nsg.id
}
