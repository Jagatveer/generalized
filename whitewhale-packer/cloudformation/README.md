# White Whale EFS

This repository contains the templates for the AWS infrastructure of the *Web EFS* application

## Infrastructure

- **VPC**: A VPC with 3 public subnets and 3 private subnets that have a route to a NAT Gateway
- **Load Balancer**: An Application Load Balancer deployed across the three public subnets
- **EFS**: An EFS file system and mount targets on each of the private subnets
- **Bastion Host**: An EC2 bastion host deployed in one of the public subnets that have a mount on the EFS volume
- **2 Web nodes**: A pair of EC2 instances behind the load balancer and with mounts of the EFS volume

## Deployment

All the infrastructure is deployed through Cloud Formatinon. To make the deployment easier the repository contains a CLI script in bash in the *[commands](commands)* folder. However you can deploy everything using *aws cli* commands

### CLI

The CLI is simple, it handles three commands:

- **create**: creates the cloudformation stack
- **update**: updates the cloudformation stack
- **sync**: uploads the templates files to S3

All the commands accept an `-e | --environment` flag which specifies which environment and configuration to use (The default is `dev`)

The region, stack name and templates bucket to use can be set in the *.env* file in the commands folder

```console
$ ./commands/cli help

  usage: cli (sync|create|update) [options]

    -e | --environment  The environment for the Stack [ dev, stage, qa, prod ]
```

### Deployment from scratch

To deploy the whole infrastructure from scratch you can follow this steps:\
(Remember to change the *.env* configuration before using the cli)

1. Edit the dev.json file with the required parameters

2. Sync the CloudFormation templates with S3

```console
$ ./commands/cf sync -e dev
```

3. Create the CloudFormation Stack

```console
$ ./commands/cf create -e dev
```
