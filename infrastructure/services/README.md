# Task Definitions

* [Task Definitions](#taskdefinitions)

## Task Definitions
A task definition is required to run Docker containers in Amazon ECS. Some of the parameters you can specify in a task definition include:

* The Docker images to use with the containers in your task
* How much CPU and memory to use with each container
* The launch type to use, which determines the infrastructure on which your tasks are hosted
* Whether containers are linked together in a task
* The Docker networking mode to use for the containers in your task
* (Optional) The ports from the container to map to the host container instance
* Whether the task should continue to run if the container finishes or fails
* The command the container should run when it is started
* (Optional) The environment variables that should be passed to the container when it starts
* Any data volumes that should be used with the containers in the task
* (Optional) The IAM role that your tasks should use for permissions

**This template is invoked from `services.yml` file.**

* **ServiceName**: Resource name.
* **StackName**: Stack name, for resource name.
* **Environment**: Environment, for resource name.
* **ContainerPort**: Port where the service listens to.
* **ConfigBucket**: Configuration bucket if needed. 
