### VPC MODULE
cidr = "10.2.0.0/16"
availability_zones  = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e","us-east-1f"]

key_name = "braulio-us-east-1"

region        = "us-east-1"

app-name = "qa"

alb_certificate = ""

app-image = "695292474035.dkr.ecr.us-east-1.amazonaws.com/braulio-siq:latest"
