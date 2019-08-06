variable "cluster" {
  description = "The name of the cluster"
}

variable "region" {
  default = ""
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "instance_type" {
  default     = "m5.large"
  description = "AWS instance type to use"
}

variable "storage" {
  default     = 100
  description = "ECS Storage"
}

variable "max_size" {
  default     = 10
  description = "Maximum size of the nodes in the cluster"
}

variable "min_size" {
  default     = 0
  description = "Minimum size of the nodes in the cluster"
}

#For more explenation see http://docs.aws.amazon.com/autoscaling/latest/userguide/WhatIsAutoScaling.html
variable "desired_capacity" {
  default     = 0
  description = "The desired capacity of the cluster"
}

variable "private_subnet_ids" {
  type        = "list"
  description = "The list of private subnets to place the instances in"
}

variable "key_name" {
  description = "SSH key name to be used"
}

variable "custom_userdata" {
  default     = ""
  description = "Inject extra command in the instance template to be run on boot"
}
