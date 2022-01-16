variable "resource_group_name" {
  description = "Name of the resource group to be imported."
  type        = string
}

variable "name_prefix" {
  description = "Name of the vnet to create"
  type        = string
}

variable "location" {
  description = "Location to create the network security group in"
  type        = string
  default     = ""
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default     = {}
}

variable "rules" {
  description = "Security rules for the network security group using this format: {subnet_name = [priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix, description]}"
  type        = any
  default     = []
}

variable "subnet_ids" {
  description = "A list of IDs to attach the network security group to"
  type        = list(string)
  default     = []
}
