# Environment variables
provider = {
  region  = "us-west-2"
}
environment = "staging"

# Network variables
vpc = {
  cidr          = "10.0.0.0/16"
  dns_hostnames = true
  dns_support   = true
  tenancy       = "default"
}
private_subnets = {
  us-west-2a = "10.0.1.0/24"
  us-west-2b = "10.0.2.0/24"
  us-west-2c = "10.0.3.0/24"
}
public_subnets = {
  us-west-2a = "10.0.4.0/24"
  us-west-2b = "10.0.5.0/24"
  us-west-2c = "10.0.6.0/24"
}
az_count = 3

# Load balancer variables ARN
alb_certificate_arn = "arn:aws:acm:us-west-2:<number>:certificate/<number>"

# Auto scaling variables
desired_capacity = 3
ecs_max_size = 3
ecs_min_size = 3
key_name = "<client>_staging"
instance_type = "t2.medium"

# Database variables
database = {
  identifier              = "<client>-staging-db"
  allocated_storage       = "200"
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "10.4"
  multi_az                = "true"
  kms_key_id              = "arn:aws:kms:us-west-2:<number>:key/<number>"
  db_user                 = "postgres"
  db_password             = "mysecretpassword"
  instance_class          = "db.t2.large"
  storage_encrypted       = "true"
  backup_retention_period = 1
}

# Service variables
service_name          = "<client>"
backfill_service_name = "backfill-<client>"
serial_service_name   = "serial-<client>"

rails_ecr             = "<number>.dkr.ecr.us-west-2.amazonaws.com/<client>_rails"
rails_tag             = "latest"
rails_cpu             = "512"
rails_mem             = "1024"
nginx_ecr             = "<number>.dkr.ecr.us-west-2.amazonaws.com/<client>_nginx"
nginx_tag             = "latest"
nginx_cpu             = "512"
nginx_mem             = "1024"
containerPort         = "80"
task_count            = "1"
cpu_up_eval_periods   = "1"
cpu_up_period         = "60"
cpu_up_threshold      = "65"
mem_up_eval_periods   = "1"
mem_up_period         = "60"
mem_up_threshold      = "65"
cpu_down_eval_periods = "1"
cpu_down_period       = "60"
cpu_down_threshold    = "20"
mem_down_eval_periods = "1"
mem_down_period       = "60"
mem_down_threshold    = "15"
delayed_mem           = "1024"
delayed_cpu           = "512"

# Elasticache variables
elasticache_engine_version  = "5.0.0"
parameter_group_name        = "default.redis5.0"
elasticache_instance_type   = "cache.t2.medium"
maintenance_window          = "sun:05:00-sun:06:00"
