cd "${BASH_SOURCE%/*}" || exit
#Master template should be one directory over commands (../)
cd ..
COMMAND=$(sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' config.yml) 
eval $COMMAND 
aws ssm put-parameter --name /EKS/DB_USER --type String --value "$DBUser"
aws ssm put-parameter --name /EKS/DB_PASSWORD --type String --value "$DBPassword"
aws ssm put-parameter --name /EKS/DD_API_KEY --type String --value "$DataDogAPIKey"
aws ssm put-parameter --name /EKS/GitHubToken --type String --value "$GitHubToken"