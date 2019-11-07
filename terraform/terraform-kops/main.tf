locals {
  vpc                 = data.terraform_remote_state.base_infra.outputs.network.vpc
  public_subnets      = data.terraform_remote_state.base_infra.outputs.network.public_subnets
  private_subnets     = data.terraform_remote_state.base_infra.outputs.network.private_subnets
}

module "kubernetes" {
  source              = "../modules/kops"
  vpc                 = local.vpc
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
  kops_cluster    = var.kops_cluster
}
