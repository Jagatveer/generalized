# share-ami-to-accounts

## lambda Code:
Function code of Lambda Resource is in developers.py or master.py. Both scripts are ZIP.  

## lambda Permissions:
Permission attached with lambda Resource is in permission.json and master_permissions.json

## Current Functionality
Overall the functionality should is as follows:

The purpose is to have EC2 AMIs created in the individual developers account shared with the rest of the individual accounts that are part of the Lumina Networks AWS organization. This was accomplished using AWS lambda and AWS CloudWatch Events in the following process.

1. A Lambda will be executed by the CloudWatch Event once a day, in each of the developers account.
2. All the EC2 AMIs that are TAGGED with `SHARED = true` will be consider by the Lambda.
3. The Lambda will share the AMIs will the Lumina Master Organization account, this account has the necessary access to list all the member accounts.
4. The Master Organization account will share the AMIs that come from the developers account with the rest of the accounts that are members of the organization.
5. Each Lambda, has the proper conditionals to avoid replication of already shared images.

In order to deploy the lambdas and the events a CloudFormation template needs to be executed, the parameters needed are simple

```
ParameterGroups:
  - Label:
      default: "Stack"
    Parameters:
      - StackName
  - Label:
      defualt: "Lambda settings"
    Parameters:
      - S3BucketName
      - S3Prefix
      - AccountType
      - MasterAccountNumber
```

StackName: Is just a name.
S3BucketName: Is the name of the bucket where the contents of this repo are located.
S3Prefix: (Optional), if a prefix is needed.
AccountType: Master or Developer, depending on the account where being deployed.
MasterAccountNumber. (Developers only) this is the master org account number. `907720735728` 

From individual Account
- Create an S3 Bucket and copy the content of this repository in the root of the bucket.
- Deploy `lambda_template.yaml` with the *developers* option and make sure to enter the account number `907720735728`.
- After deployment tag any AMI of the SAME region (`us-west-1`, by default right now) with `SHARED = true`. -> this means that any AMI to be shared needs to be on us-west-1
- Every night the images will be shared with the master account where they will be shared with the rest of Lumina's team.

From Master Account
- Create an S3 Bucket and copy the content of this repository in the root of the bucket.
- Deploy `lambda_template.yaml` with the *master* option.
- Every night the images will be copied and shared with the rest of Lumina's team.
