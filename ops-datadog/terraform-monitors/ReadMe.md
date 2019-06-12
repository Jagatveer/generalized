# DataDog Monitors with Terraform

This terraform templates will create some basic DataDog monitors for EC2 instances

### Getting Started

To use the templates first you have to set the *DataDog App Key* and the *DataDog API Key* in the **terraform.tfvars** file

```
datadog_api_key = "<DD_API_KEY>"
datadog_app_key = "<DD_APP_KEY>"
```

Then you just have to run the terraform templates:

```
$ terraform plan
$ terraform apply
```