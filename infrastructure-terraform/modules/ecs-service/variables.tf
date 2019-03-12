/* Terraform constraints */
terraform {
    required_version = ">= 0.11, < 0.12"
}

variable "environment" {
    default = ""
}

variable "region" {
  default = ""
}

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

variable "ecs-cluster" {
    default = ""
    description = "Insert the ecs cluster id where tasks are to be placed"
}

variable "task_count" {
    default = 1
    description = "Number of tasks to run"
}

variable "alb-tg-arn" {
    default = ""
    description = "Insert the arn of alb attached to service"
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