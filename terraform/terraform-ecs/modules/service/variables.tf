variable "vpc_id" {
  default = ""
}

variable "region" {
  default = ""
}

variable "cluster_id" {
  default = ""
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "350072593941.dkr.ecr.us-east-1.amazonaws.com/transitions-nclouds:latest"
}

variable "app_name" {
  default = "jenkins-siq"
}

variable "environment" {
  default = "qa"
}

variable "app_port" {
  default = "8080"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "cpu" {
  description = "Container CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "memory" {
  description = "Container memory to provision (in MiB)"
  default     = "1024"
}

variable "health_check" {
  description = "The health check path for the service"
  default     = "/login"
}

variable "listener" {
  description = "The listener to use"
  default     = ""
}
