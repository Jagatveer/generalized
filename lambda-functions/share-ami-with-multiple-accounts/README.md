# share-ami-to-accounts

## lambda Code:
Function code of Lambda Resource is in lambda_function.py

## lambda Permissions:
Permission attached with lambda Resource is in permission.json

## Current Functionality

- Right now, our script is sharing single AMI from a account to multiple accounts
- Add "create volume" permissions to the following associated snapshots when creating permissions
- Gets all the newly shared  AMIs using tags

## Remaining Functionality
- List all org accounts and then share the newly created copies with the listed accounts

## Access Required for completing task
- Master account which can fetch org accounts
