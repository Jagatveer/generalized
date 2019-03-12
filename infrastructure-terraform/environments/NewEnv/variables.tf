# Environment variables
variable "environment" {
  default = ""
}
variable "provider" {
  type = "map"
}

# Network variables
variable "vpc" {
  type = "map"
}
variable "public_subnets" {
  type = "map"
}
variable "private_subnets" {
  type = "map"
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
}

# Database variables
variable "database" {
  type = "map"
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
