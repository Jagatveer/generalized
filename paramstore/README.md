* Add parameter Store scripts to Dockerfile * 

The contents of this repository are used to retrieve parameters from AWS Parameter Store, given a certain hierarchy specified in the _start.sh_ script.
In order to implement this feature in your docker image follow the next steps:

For each service, create a Dockerfile (if it isn't already created).
Add necessary steps to install nodejs in the container.
Copy the contents of this repository into the container.
Add custom Entrypoint pointing to _start.sh_ with the startup command as second parameter.