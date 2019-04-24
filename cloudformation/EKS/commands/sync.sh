cd "${BASH_SOURCE%/*}" || exit
cd ..
COMMAND=$(sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' config.yml)
eval $COMMAND
aws s3 sync . "s3://$S3BucketName/$S3KeyPrefix" --exclude "*" --include "*.yml" --include "*.zip"