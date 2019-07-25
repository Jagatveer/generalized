### GENERAL ###
variable "region" {
  type = "string"
  description = "aws region"
}

variable "environment" {}
variable "cluster_name" {}

### VPC MODULE ###
variable "vpc" {
   type = "map"
}

variable "public_subnets" {
   type = "list"
}

variable "private_subnets" {
   type = "list"
}

### KUBERNETES MODULE ###
variable "kops_state_bucket" {}
variable "worker_node_type" {}
variable "min_worker_nodes" {}
variable "max_worker_nodes" {}
variable "master_node_type" {}
