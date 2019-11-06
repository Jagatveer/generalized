# White Whale Packer Image

## Run this command for building this image.
packer build -var 'aws_access_key=${}' -var 'aws_secret_key=${}' whitewhale.json


## Hardcoded things in code:
 - Oregon region and its Ubuntu 18 source_ami is hardcoded

## Parameters
- aws access key for AWS authentication
- aws secret key for AWS authentication
