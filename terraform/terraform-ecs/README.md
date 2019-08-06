### Terraform

## Prerequisites

- Terraform v0.11.11
- Pem key already created
- S3 Bucket
- Dynamo table with string key `LockID`
## Deploy your environment [dev,qa,prod]

Make sure that your backend configuration files are set properly, these files are located inside the config folder, make sure that the bucket and dynamo table exist, the dynamo table must have the string key `LockID`.

Modify your environment parameters on the tfvars file inside the config folder, make sure that your vpc CIDR does not overlaps between environments, add the name of your pem key to the worker map variable.

```sh
terraform init
env=qa
terraform workspace select ${env} || terraform workspace new ${env}
terraform apply -var-file=config/${env}.tfvars
```

### Destroy the cluster

```sh
env=qa
terraform workspace select ${env}
terraform destroy -var-file=config/${env}.tfvars

```
