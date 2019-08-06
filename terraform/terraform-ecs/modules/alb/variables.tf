variable "lb_name" {
  default = ""
}
variable "lb_is_internal" {
  default = false
}
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
