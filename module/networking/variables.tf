variable "resource_group_name" {
  description = "Resource group where networking resources will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for networking resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR range for the virtual network"
  type        = string
}

variable "funcapp_subnet_name" {
  description = "Name of the Function App subnet"
  type        = string
}

variable "funcapp_subnet_cidr" {
  description = "CIDR range for the Function App subnet"
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "Name of the Private Endpoint subnet"
  type        = string
}

variable "private_endpoint_subnet_cidr" {
  description = "CIDR range for the Private Endpoint subnet"
  type        = string
}

variable "funcapp_nsg_name" {
  description = "Name of the NSG attached to the Function App subnet"
  type        = string
}

variable "private_endpoint_nsg_name" {
  description = "Name of the NSG attached to the Private Endpoint subnet"
  type        = string
}

# variable "tags" {
#   description = "Tags applied to networking resources"
#   type        = string
# }

# keyvalue pairs

variable "tags" {
  description = "Tags applied to networking resources"
  type        = map(string)
  default     = {}
}
