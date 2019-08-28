# Uploading parameters and secrets

This script will upload parameters to parameter store

## Getting Started

These instructions will allow you to update secrets values on secret manager and non-secret values on parameter store.

### Prerequisites

Select the correct AWS profile, install the requirements for the script.
```
export AWS_PROFILE=nd
pip install -r requirement.txt
```
The parameter.json file have the following format.
```
{
  "parameters":{
    "parameter1":"value1"
    "parameter2":"value2"
  }
}
```
Fill your file with that format. the script will replace or create  (if it doesnt exist) the parameters.

### Optional post installation

You can copy the ssmcli.py file to your /usr/local/bin/ with the name *ssmcli*, so you can use it as you were using another cli, without invoking it with python.

### Usage

This cli has six methods.

##### add-parameters

This method is going to read the parameter_file and will  create the parameters that are written on that file, but it will add the prefix_name to each one of those.


| Parameter Name | Parameter Type | Effect | Default value | Optional |
| --- | --- | --- | --- | --- |
| prefix_name | argument | the prefix you want to add to all the parameters that you set in the json file |  | YES |
| --parameters_file | option | The path to the json file, where all the parameters are created. | ./parameters.json | NO |
| --region | option | the region where you want to deploy the parameters | us-east- 1| NO |


##### add-single-parameter

This method is going to add a parameter, see that this method, does not ask for prefix_name, so you need to write the entire name of the parameter and also its value, the value will be encrypted with KMS.

| Parameter Name | Parameter Type | Effect | Default value | Optional |
| --- | --- | --- | --- | --- |
| parameter_name | argument | The parameter name, include the prefix as well |  | YES |
| value | argument | The value for the parameter |  | YES |
| --region | option | the region where you want to deploy the parameters | us-east- 1| NO |



##### delete-parameters

This method is going to read the parameter_file and will delete the parameters that are written on that file, a prefix prefix_name will be added to that parameter before trying to delete it

| Parameter Name | Parameter Type | Effect | Default value | Optional |
| --- | --- | --- | --- | --- |
| prefix_name | argument | the prefix you want to add to all the parameters that you set in the json file |  | YES |
| --parameters_file | option | The path to the json file, where all the parameters are specified. | ./parameters.json | NO |
| --region | option | the region where you want to deploy the parameters | us-east- 1| NO |



#####delete-single-parameter
This method is going to delete a parameter, see that this method, does not ask for prefix_name, so you need to write the entire name of the parameter.

| Parameter Name | Parameter Type | Effect | Default value | Optional |
| --- | --- | --- | --- | --- |
| parameter_name | argument | The parameter name, include the prefix as well |  | YES |
| --region | option | the region where you want to deploy the parameters | us-east- 1| NO |


#####list-parameters

This method will list all the parameters that match the prefix name in the stdout, Optionaly you can output the content of this method to a file with the output_file option, so you can use that file to further operations with delete_parameters and add_parameters Generally helpfull when you want to delete all the variables of an environment, or you want to create a copy of the variables of an environment. The output file of this method is ready to use with add_parameters and delete_parameters methods

| Parameter Name | Parameter Type | Effect | Default value | Optional |
| --- | --- | --- | --- | --- |
| prefix_name | argument | the prefix variables you want to list |  | YES |
| --output_file | option | The path to the json file, where all the parameters will be written. |  | NO |
| --region | option | the region where you want to deploy the parameters | us-east- 1| NO |


#####list-prefixes

This method is going to check your aws account, in the region that you set and it will show you, the current prefixes that are already created.

| Parameter Name | Parameter Type | Effect | Default value | Optional |
| --- | --- | --- | --- | --- |
| --region | option | the region where you want to list prefixes | us-east- 1| NO |
