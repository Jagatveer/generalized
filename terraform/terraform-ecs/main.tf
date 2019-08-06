module "vpc" {
  source          = "modules/network"
  availability_zones     = "${var.availability_zones}"
  cidr                   = "${var.cidr}"
}

module "ecs" {
  source             = "modules/ecs"
  vpc_id             = "${module.vpc.vpc_id}"
  cluster            = "siq_jenkins"
  private_subnet_ids = "${module.vpc.private_subnets_ids}"
  region             = "${var.region}"
  key_name           = "${var.key_name}"
  desired_capacity   = "1"
}

module "alb" {
  source              = "modules/alb"
  vpc_id              = "${module.vpc.vpc_id}"
  lb_is_internal      = false
  lb_name             = "siq-jenkins-alb"
  subnet_ids          = "${module.vpc.public_subnets_ids}"
  alb_certificate_arn = "${var.alb_certificate}"
}

module "service" {
  source     = "modules/service"
  app_name   = "jenkins-siq"
  vpc_id     = "${module.vpc.vpc_id}"
  region     = "${var.region}"
  app_image  = "${var.app-image}"
  cluster_id = "${module.ecs.ecs}"
  listener   = "${module.alb.http_listener_arn}"
}
