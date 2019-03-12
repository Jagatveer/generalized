variable "environment" {
  default = ""
}

variable "database" {
  type        = "map"
  description = "Database settings"

  default = {
    identifier              = ""
    allocated_storage       = 10
    storage_type            = ""
    engine                  = ""
    engine_version          = ""
    multi_az                = ""
    kms_key_id              = ""
    db_user                 = ""
    db_password             = ""
    instance_class          = ""
    storage_encrypted       = true
    backup_retention_period = 1
  }
}

variable "vpc_id" {
  default = ""
}

variable "private_subnet_ids" {
  type    = "list"
}

variable "instance-sg" {
  default = ""
  description = "Security group of instance which will acccess RDS"
}
