variable "cidr" {}

variable "availability_zones" {
  type = "list"
}
variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "The name of the key to use in the ASG"
}
variable "app-name" {
  description = "The name of app"
}
variable "alb_certificate" {
  description = "The ca_certificate to use in the application"
}
variable "app-image" {
  description = "The image to use in the application"
}
