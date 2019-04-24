cd "${BASH_SOURCE%/*}" || exit
#Master template should be one directory over commands (../)
cd ..
COMMAND=$(sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' config.yml) 
eval $COMMAND 
aws cloudformation create-stack --region "$Region" --stack-name "$StackName" --template-body file://master.yml --parameters \
  ParameterKey=S3BucketName,ParameterValue="$S3BucketName" \
  ParameterKey=S3KeyPrefix,ParameterValue="$S3KeyPrefix" \
  ParameterKey=Environment,ParameterValue="$Environment" \
  ParameterKey=KeyPair,ParameterValue="$KeyPair" \
  --capabilities CAPABILITY_NAMED_IAM