/* Terraform constraints */
terraform {
  required_version = ">= 0.11, < 0.12"
}

variable "region" {
  default = "us-west-2"
  description = "Determine AWS region endpoint to access."
}

variable "environment" {
  default= ""
}

variable "service_name" {
  default = ""
}

variable "vpc_id" {
  default= ""
}

variable "desired_capacity" {
  default = 1
  description = "Number of instance to run"
}

variable "ecs_max_size" {
  default = 2
}

variable "ecs_min_size" {
  default = 1
}

variable "key_name" {
  default = "<client>_staging"
}

variable "instance_type" {
  default = ""
  description = "EC2 instance type to use"
}

variable "alb-sg" {
  default = ""
  description = "Security group of ALB"
}

variable "private_subnet_ids" {
  default = []
  type    = "list"
}
