terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-remote-state-<env>"
    dynamodb_table = "terraform-state-lock-<env>"
    region = "us-west-2"
    key = "terraform.tfstate"
  }
}
