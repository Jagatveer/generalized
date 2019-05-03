# CI / CD

This module creates the infrastructure for a continuous integration / continuous delivery pipeline using a Jenkins Master-Slave architecture running on ECS.

![Jenkins Infrastructure](../images/Jenkins.png)

## Jenkins
The Jenkins containers use a Master-Slave achitecture with the following characteristics:
- The Jenkins configuration is managed with *Groovy* scripts, so manual configuration is not needed
- The docker socket of the host is mounted as a volume on the containers to let the Jenkins Slaves run Docker commands
- The Logs of the Jenkins containers are sent to *CloudWatch*

## Pipeline

![Pipeline](../images/Pipeline.png)

### Hadolint

Hadolint is a smart Dockerfile linter that helps you build best practice Docker images. The linter parses the Dockerfile and perform rules on top of it to see if it complies with all the best practices.
You can find more information on the [Hadolint Repo](https://github.com/hadolint/hadolint)

### Vulnerability Scanner

The Jenknins pipeline uses a [vulnerability scanner](../coreos-clair) to analyze the images before pushing and deploying the new image. This Enforces security best practices, catches human erros and prevents security breaches on our live environment

### Blue / Green Deployment

Jenkins manages a Blue / Green deployment by using a parameter on *Parameter Store* to know which is the actual Production environment and then decides to deploy to one environment or another

![Blue Green](../images/BlueGreen.png)

## Cloud Formation

The stack template receives the following parameters:

- VpcId
- PublicSubnetsIds
- PrivateSubnetsIds
- ClusterName
- KeyPair
- QSS3BucketName
- QSS3KeyPrefix
- Environment
- StackName
