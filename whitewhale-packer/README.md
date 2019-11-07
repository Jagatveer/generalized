#use case: Need to setup/configure SFTP and Bastion on the same node . 
- EFS as a centralized storage and creating sftp users on efs as well. 
- Mount EFS on /home directory 
- Configure SFTP chroot jailed users on efs
- Apache user need to access individual SFTP user directory for vhost rootDoucment path.

# White Whale Packer Image

## Run this command for building this image.
packer build -var 'aws_access_key=${}' -var 'aws_secret_key=${}' whitewhale.json

For example

packer build -var 'aws_access_key=23434fdf233' -var 'aws_secret_key=2321df2342dwer2vefwref' whitewhale.json



## Hardcoded things in code:
 - Oregon region and its Ubuntu 18 source_ami is hardcoded

## Parameters
- aws access key for AWS authentication
- aws secret key for AWS authentication

## Structure
- Files

Files need to be on Ubuntu Instance
- Scripts

Shell Script to install all configurations and move files to respective directories
