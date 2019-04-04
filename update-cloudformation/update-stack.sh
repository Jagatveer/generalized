#!/bin/bash
export AWS_PROFILE=<client>
aws s3 sync "$PWD/" s3://bucket-cloudformation/ --exclude "*" --include "*.template" --include "*.yaml" --include "*.yml" --delete

AWS_REGION="us-west-2"
STACK_NAME="CloudFormationStackName"
TEMPLATE_URL="https://s3-$AWS_REGION.amazonaws.com/bucket_name/object_key.yaml"

aws cloudformation update-stack \
--stack-name $STACK_NAME \
--template-url $TEMPLATE_URL \
--capabilities CAPABILITY_NAMED_IAM \
--profile iam_profile \
--region $AWS_REGION \
--parameters="file://$PWD/$STACK_NAME.json"
