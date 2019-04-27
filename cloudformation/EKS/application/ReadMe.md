# Go Application

This is an example of CRUD web application writen in Go that makes use of a Postgres database

## Dockerfile

- The Dockerfile uses *Multi-Stage* to build the application so just Docker is needed to build the application
- The layers or the Dockerfile are organized to optimize the image
- The Docker image also uses the *aws-env* to handle enviromental variables using *Parameter Store*. You can get more information in the [aws-env Repo](https://github.com/Droplr/aws-env)

### Hadolint

Hadolint is a smart Dockerfile linter that helps you build best practice Docker images. The linter parses the Dockerfile and perform rules on top of it to see if it complies with all the best practices.
You can find more information on the [Hadolint Repo](https://github.com/hadolint/hadolint)

## Local Environment

You can run the application in a local environment using Docker Compose, this runs the container of the application alongside a postgres container

To run the application locally:

```bash
docker-compose build
```
```bash
docker-compose run
```

## Getting Started

You need to push the image to ECR repository for the EKS infrastructure

```bash
$(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
docker build -t <repository_uri>:latest .
docker push <repository_uri>:latest
```
