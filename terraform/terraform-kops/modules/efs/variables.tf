variable "environment" {}
variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_count" {}
variable "private_subnets" {
  type        = "list"
  default     = []
}
