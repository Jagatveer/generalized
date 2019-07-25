module "vpc" {
  source          = "./modules/vpc"
  environment     = "${var.environment}"
  vpc             = "${var.vpc}"
  cluster_name    = "${var.cluster_name}"
  public_subnets  = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"
}

locals {
  private_subnets = [
    {
      id    = "${element(module.vpc.private_subnets_ids,0)}"
      cidr  = "${element(module.vpc.private_subnets_cidrs,0)}"
      zone  = "${element(module.vpc.private_subnets_azs,0)}"
    },
    {
      id    = "${element(module.vpc.private_subnets_ids,1)}"
      cidr  = "${element(module.vpc.private_subnets_cidrs,1)}"
      zone  = "${element(module.vpc.private_subnets_azs,1)}"
    },
    {
      id    = "${element(module.vpc.private_subnets_ids,2)}"
      cidr  = "${element(module.vpc.private_subnets_cidrs,2)}"
      zone  = "${element(module.vpc.private_subnets_azs,2)}"
    }
  ]
  public_subnets = [
    {
      id    = "${element(module.vpc.public_subnets_ids,0)}"
      cidr  = "${element(module.vpc.public_subnets_cidrs,0)}"
      zone  = "${element(module.vpc.public_subnets_azs,0)}"
    },
    {
      id    = "${element(module.vpc.public_subnets_ids,1)}"
      cidr  = "${element(module.vpc.public_subnets_cidrs,1)}"
      zone  = "${element(module.vpc.public_subnets_azs,1)}"
    },
    {
      id    = "${element(module.vpc.public_subnets_ids,2)}"
      cidr  = "${element(module.vpc.public_subnets_cidrs,2)}"
      zone  = "${element(module.vpc.public_subnets_azs,2)}"
    }
  ]
}

module "efs" {
  source                = "./modules/efs"
  environment           = "${var.environment}"
  cluster_name          = "${var.cluster_name}"
  private_subnet_count  = "${length(var.private_subnets)}"
  private_subnets       = "${module.vpc.private_subnets_ids}"
  vpc_id                = "${module.vpc.vpc_id}"
}

module "kubernetes" {
  source              = "./modules/kubernetes"
  cluster_name        = "${var.cluster_name}"
  dns_zone            = "k8s.local"
  kubernetes_version  = "1.12.8"
  state_bucket        = "${var.kops_state_bucket}"
  node_image          = "kope.io/k8s-1.12-debian-stretch-amd64-hvm-ebs-2019-05-13"
  vpc_id              = "${module.vpc.vpc_id}"
  vpc_cidr            = "${module.vpc.vpc_cidr}"
  region              = "${var.region}"
  public_subnets      = "${local.public_subnets}"
  private_subnets     = "${local.private_subnets}"
  worker_node_type    = "${var.worker_node_type}"
  min_worker_nodes    = "${var.min_worker_nodes}"
  max_worker_nodes    = "${var.max_worker_nodes}"
  master_node_type    = "${var.master_node_type}"
}
