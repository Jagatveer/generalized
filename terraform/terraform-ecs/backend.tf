terraform {
  required_version = "~> 0.10"
  backend "s3"{
    bucket                 = "braulio-test"
    region                 = "us-east-1"
    key                    = "backend.tfstate"
    workspace_key_prefix   = "ecs"
    # dynamodb_table         = "terraform-lock"
  }
}
