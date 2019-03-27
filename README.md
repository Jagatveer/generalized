# KPOD1 Generalized templates
This branch is meant to create general templates for the team. All team members must use this templates and help to improve them.

## Rules
1. Commit similar resources together, for e.g. Compute, Autoscaling, Cloudwatch should be separate from storage, network or other services. In Compute, we can have further division into Beanstalk, ECS, EKS, etc. depending on launch type.

2. Update existing folder only in case of functional upgrade. Create Pull Request and need to be reviewed by at least three members of KPOD1.

3. Do not use resource id or client specific parameters in the resource declaration file.

4. Use conditionals for recurring use cases of resource linkage. For eg. IAM Policy attachment, target group attachment, autoscaling attachment etc.

5. If you want to commit a new application create a new folder called *application*-cloudformation, for e.g. Jenkins in CloudFormation: jenkins-cloudformation.

6. Create README.md for each folder you create. This will help us to create documentation.

### CloudFormation Rules
1. All parameters must have default values.

2. Use NoEcho property to obfuscate sensitive values in parameters

3. Use CloudFormation *Metadata* for master templates to be user friendly.

4. Use *yml* syntax as much as possible. Try to not create IAM policies or any other type using json syntax.

### Terraform Rules
1. Rule

![Terraform Rules](images/terraformmodules.png)

## Best practices
+ Use always the core infrastructure to have all the features so we can start improving our generalized repository.

+ If you want to make a change in the core infrastructure, rise a PR and let all of the team review it. In this way we ensure we use the best possible solution in all clients.

+ Don't commit any resource id, company name nor account id. Make sure of it. Instead use the word *company*.
