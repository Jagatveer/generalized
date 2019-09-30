# share-ami-to-accounts

## lambda Code:
Function code of Lambda Resource is in lambda_function.py

## lambda Permissions:
Permission attached with lambda Resource is in permission.json

## Current Functionality
From individual Account
- Right now, our script is sharing single AMI from a account to multiple accounts
- Add "create volume" permissions to the following associated snapshots when creating permissions
- Gets all the newly shared  AMIs using tags

From Master Account
- List all org accounts and then share the newly created copies with the listed accounts
- Add "create volume" permissions to the following associated snapshots when creating permissions
