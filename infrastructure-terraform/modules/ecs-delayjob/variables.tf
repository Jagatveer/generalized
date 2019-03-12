/* Terraform constraints */
terraform {
    required_version = ">= 0.11, < 0.12"
}

variable "region" {
    default = ""
}

variable "environment" {
    default = ""
}

variable "service_name" {
    default = ""
    description = "Name of the delayjob default service"
}

variable "ecs_task_role" {
  default = ""
}

variable "ecs-cluster" {
    default = ""
    description = "Insert the ecs cluster id where tasks are to be placed"
}

variable "rails_ecr" {
    default = ""
    description = "ecr repo name for rails app"
}

variable "rails_tag" {
    default = ""
    description = "tag for rails app in ecr"
}

variable "delayed_mem" {
    default = ""
    description = "memory limit for delayed jobs"
}

variable "delayed_cpu" {
    default = ""
    description = "cpu limit for delayed jobs"
}

variable "ecs_scalabletarget_role" {
  default = ""
}
