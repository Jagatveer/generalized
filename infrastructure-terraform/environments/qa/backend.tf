terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-remote-state-qa"
    dynamodb_table = "terraform-state-lock-qa"
    region = "us-west-2"
    key = "terraform.tfstate"
  }
}
