# share-ami-to-accounts

## lambda Code:
Function code of Lambda Resource is in developers.py or master.py. Both scripts are ZIP.  

## lambda Permissions:
Permission attached with lambda Resource is in permission.json and master_permissions.json

## Current Functionality
From individual Account
- Create an S3 Bucket and copy the content of this repository in the root of the bucket.
- Deploy `lambda_template.yaml` with the *developers* option and make sure to enter the account number `907720735728`.
- After deployment tag any AMI of the SAME region `us-west-1` with `SHARED = true`. -> this means that any AMI to be shared needs to be on us-west-1
- Every night the images will be shared with the master account where they will be shared with the rest of Lumina's team.

From Master Account
- Create an S3 Bucket and copy the content of this repository in the root of the bucket.
- Deploy `lambda_template.yaml` with the *master* option.
- Every night the images will be copied and shared with the rest of Lumina's team.
