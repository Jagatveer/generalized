variable "vpc_id" {
  default = ""
}

variable "subnet_ids" {
  default = []
  type    = "list"
}

variable "alb_certificate_arn" {
  default = ""
}

variable "environment" {
  default = ""
}

variable "containerPort" {
  default = ""
}
