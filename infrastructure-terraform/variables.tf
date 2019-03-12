# Environment variables
variable "environment" {
  default = ""
}
variable "region" {
  default = ""
  description = "aws region"
}

# Network variables
variable "vpc" {
  type        = "map"
  description = "Map of AWS VPC settings"

  default = {
    cidr          = "10.0.0.0/16"
    dns_hostnames = true
    dns_support   = true
    tenancy       = "default"
  }
}
variable "public_subnets" {
  type        = "map"
  description = "Map of AWS availability zones (key) to subnet CIDR (value) assignments"

  default = {
    us-west-2a = "10.0.1.0/24"
    us-west-2b = "10.0.2.0/24"
    us-west-2c = "10.0.3.0/24"
  }
}
variable "private_subnets" {
  type        = "map"
  description = "Map of AWS availability zones (key) to subnet CIDR (value) assignments"

  default = {
    us-west-2a = "10.0.4.0/24"
    us-west-2b = "10.0.5.0/24"
    us-west-2c = "10.0.6.0/24"
  }
}
variable "az_count" {}

# Load balancer variables
variable "alb_certificate_arn" {
  default = ""
}

# Auto scaling variables
variable "desired_capacity" {}
variable "ecs_max_size" {}
variable "ecs_min_size" {}
variable "key_name" {}
variable "instance_type" {
    default = ""
    description = "Type of instance to be launched"
}

# Database variables
variable "database" {
  type        = "map"
  description = "Database settings"

  default = {
    identifier              = ""
    allocated_storage       = 10
    storage_type            = ""
    engine                  = ""
    engine_version          = ""
    multi_az                = ""
    kms_key_id              = ""
    db_user                 = ""
    db_password             = ""
    instance_class          = ""
    storage_encrypted       = true
    backup_retention_period = 1
  }
}

# Service variables
variable "service_name" {
    default = ""
}
variable "rails_ecr" {
  default = ""
}
variable "rails_tag" {
  default = ""
}
variable "rails_cpu" {
  default = ""
}
variable "rails_mem" {
  default = ""
}
variable "nginx_ecr" {
  default = ""
}
variable "nginx_tag" {
  default = ""
}
variable "nginx_cpu" {
  default = ""
}
variable "nginx_mem" {
  default = ""
}
variable "containerPort" {
  default = ""
}
variable "task_count" {
    default = 1
    description = "Number of tasks to run"
}
variable "cpu_up_period" {
    default = ""
    description = "Period for cpu_up Cloudwatch alarm"
}
variable "cpu_up_threshold" {
    default = ""
    description = "Threshold for cpu_up Cloudwatch alarm"
}
variable "cpu_up_eval_periods" {
    default = ""
    description = "Evaluation Periods for cpu_up Cloudwatch alarm"
}
variable "mem_up_period" {
    default = ""
    description = "Period for mem_up Cloudwatch alarm"
}
variable "mem_up_threshold" {
    default = ""
    description = "Threshold for mem_up Cloudwatch alarm"
}
variable "mem_up_eval_periods" {
    default = ""
    description = "Evaluation Periods for mem_up Cloudwatch alarm"
}
variable "cpu_down_period" {
    default = ""
    description = "Period for cpu_down Cloudwatch alarm"
}
variable "cpu_down_threshold" {
    default = ""
    description = "Threshold for cpu_down Cloudwatch alarm"
}
variable "cpu_down_eval_periods" {
    default = ""
    description = "Evaluation Periods for cpu_down Cloudwatch alarm"
}
variable "mem_down_period" {
    default = ""
    description = "Period for mem_down Cloudwatch alarm"
}
variable "mem_down_threshold" {
    default = ""
    description = "Threshold for mem_down Cloudwatch alarm"
}
variable "mem_down_eval_periods" {
    default = ""
    description = "Evaluation Periods for mem_down Cloudwatch alarm"
}
variable "delayed_mem" {
    default = ""
    description = "memory limit for delayed jobs"
}
variable "delayed_cpu" {
    default = ""
    description = "cpu limit for delayed jobs"
}
# Elasticache variables
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
