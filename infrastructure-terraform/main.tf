module "vpc" {
  source          = "modules/network"
  environment     = "${var.environment}"
  vpc             = "${var.vpc}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
  az_count       = "${var.az_count}"
}

module "alb" {
  source              = "modules/alb"
  environment         = "${var.environment}"
  vpc_id              = "${module.vpc.vpc_id}"
  subnet_ids          = "${module.vpc.public_subnets_ids}"
  alb_certificate_arn = "${var.alb_certificate_arn}"
  containerPort       = "${var.containerPort}"
}

module "ecs-autoscaling" {
  source              = "modules/ecs-autoscaling"
  environment         = "${var.environment}"
  service_name        = "${var.service_name}"
  vpc_id              = "${module.vpc.vpc_id}"
  desired_capacity    = "${var.desired_capacity}"
  ecs_max_size        = "${var.ecs_max_size}"
  ecs_min_size        = "${var.ecs_min_size}"
  key_name            = "${var.key_name}"
  instance_type       = "${var.instance_type}"
  alb-sg              = "${module.alb.alb-sg}"
  private_subnet_ids  = "${module.vpc.private_subnets_ids}"
}

module "rds" {
  source              = "modules/rds"
  environment         = "${var.environment}"
  vpc_id              = "${module.vpc.vpc_id}"
  private_subnet_ids  = "${module.vpc.private_subnets_ids}"
  database            = "${var.database}"
  instance-sg         = "${module.ecs-autoscaling.instance-sg}"
}

module "ecs-service" {
  source                = "modules/ecs-service"
  environment           = "${var.environment}"
  region                = "${var.region}"
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
  ecs-cluster           = "${module.ecs-autoscaling.ecs-cluster-id}"
  task_count            = "${var.task_count}"
  alb-tg-arn            = "${module.alb.alb-tg}"
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
}

module "ecs-delayjob" {
  source                  = "modules/ecs-delayjob"
  environment             = "${var.environment}"
  region                  = "${var.region}"
  service_name            = "${var.service_name}"
  ecs-cluster             = "${module.ecs-autoscaling.ecs-cluster-id}"
  rails_ecr               = "${var.rails_ecr}"
  rails_tag               = "${var.rails_tag}"
  delayed_cpu             = "${var.delayed_cpu}"
  delayed_mem             = "${var.delayed_mem}"
  ecs_task_role           = "${module.ecs-service.ecs_task_role}"
  ecs_scalabletarget_role = "${module.ecs-service.ecs_scalabletarget_role}"
}

module "cdn-s3" {
  source                  = "modules/cloudfront"
  environment             = "${var.environment}"
  service_name            = "${var.service_name}"
}

module "elasticache-redis"{
  source                      = "modules/elasticache"
  environment                 = "${var.environment}"
  service_name                = "${var.service_name}"
  vpc_id                      = "${module.vpc.vpc_id}"
  private_subnet_ids          = "${module.vpc.private_subnets_ids}"
  elasticache_engine_version  = "${var.elasticache_engine_version}"
  parameter_group_name        = "${var.parameter_group_name}"
  elasticache_instance_type   = "${var.elasticache_instance_type}"
  maintenance_window          = "${var.maintenance_window}"
  ecs_security_group          = "${module.ecs-autoscaling.instance-sg}"
}
