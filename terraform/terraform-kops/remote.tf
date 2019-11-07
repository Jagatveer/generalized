# Remote state of management VPC
data "terraform_remote_state" "base_infra" {
  backend   = "s3"
  config = {
    bucket  = ""
    key     = "base_infra/${terraform.workspace}/backend.tfstate"
    region  = ""
  }
}
