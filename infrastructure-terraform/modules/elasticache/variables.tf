variable "vpc_id" {
  default = ""
}
variable "environment" {
  default = ""
}
variable "private_subnet_ids" {
  type    = "list"
}
variable "elasticache_engine_version" {
  default = ""
}
variable "parameter_group_name" {
  default = ""
}
variable "elasticache_instance_type" {
  default = ""
}
variable "maintenance_window" {
  default = ""
}

variable "service_name" {
  default = ""
}

variable "ecs_security_group" {
  default = ""
}
