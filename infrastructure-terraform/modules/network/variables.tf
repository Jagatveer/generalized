variable "vpc" {
  type        = "map"
  description = "Map of AWS VPC settings"

  default = {
    cidr          = ""
    dns_hostnames = true
    dns_support   = true
    tenancy       = "default"
  }
}

variable "environment" {
  type = "string"
  default = ""
}

variable "public_subnets" {
  type = "map"
  description = "Map of AWS availability zones (key) to subnet CIDR (value) assignments"

  default = {
    us-west-2a = ""
  }
}

variable "private_subnets" {
  type = "map"
  description = "Map of AWS availability zones (key) to subnet CIDR (value) assignments"

  default = {
    us-west-2a = ""
  }
}

variable "az_count" {}
