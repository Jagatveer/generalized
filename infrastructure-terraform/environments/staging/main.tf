provider "aws" {
  region  = "${var.provider["region"]}"
}


module "staging" {
  source                = "../../"
  # Environment
  environment           = "${var.environment}"
  region                = "${var.provider["region"]}"
  # Network
  vpc                   = "${var.vpc}"
  public_subnets        = "${var.public_subnets}"
  private_subnets       = "${var.private_subnets}"
  az_count              = "${var.az_count}"
  # ALB
  alb_certificate_arn   = "${var.alb_certificate_arn}"
  # Auto scaling
  desired_capacity      = "${var.desired_capacity}"
  ecs_max_size          = "${var.ecs_max_size}"
  ecs_min_size          = "${var.ecs_min_size}"
  key_name              = "${var.key_name}"
  instance_type         = "${var.instance_type}"
  # Database
  database              = "${var.database}"
  # Service
  service_name          = "${var.service_name}"
  rails_ecr             = "${var.rails_ecr}"
  rails_tag             = "${var.rails_tag}"
  rails_cpu             = "${var.rails_cpu}"
  rails_mem             = "${var.rails_mem}"
  nginx_ecr             = "${var.nginx_ecr}"
  nginx_tag             = "${var.nginx_tag}"
  nginx_cpu             = "${var.nginx_cpu}"
  nginx_mem             = "${var.nginx_mem}"
  containerPort         = "${var.containerPort}"
  task_count            = "${var.task_count}"
  cpu_up_eval_periods   = "${var.cpu_up_eval_periods}"
  cpu_up_period         = "${var.cpu_up_period}"
  cpu_up_threshold      = "${var.cpu_up_threshold}"
  mem_up_eval_periods   = "${var.mem_up_eval_periods}"
  mem_up_period         = "${var.mem_up_period}"
  mem_up_threshold      = "${var.mem_up_threshold}"
  cpu_down_eval_periods = "${var.cpu_down_eval_periods}"
  cpu_down_period       = "${var.cpu_down_period}"
  cpu_down_threshold    = "${var.cpu_down_threshold}"
  mem_down_eval_periods = "${var.mem_down_eval_periods}"
  mem_down_period       = "${var.mem_down_period}"
  mem_down_threshold    = "${var.mem_down_threshold}"
  delayed_mem           = "${var.delayed_mem}"
  delayed_cpu           = "${var.delayed_cpu}"
  # Elasticache
  elasticache_engine_version  = "${var.elasticache_engine_version}"
  parameter_group_name        = "${var.parameter_group_name}"
  elasticache_instance_type   = "${var.elasticache_instance_type}"
  maintenance_window          = "${var.maintenance_window}"
}
