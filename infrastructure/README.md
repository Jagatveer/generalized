# client infrastructure

* [Nested stacks](#nested)
* [Naming & Location](#location)
* [VPC](#vpc)
* [Security](#security)

## Nested stacks
Nested stacks are stacks created as part of other stacks. You create a nested stack within another stack by using the AWS::CloudFormation::Stack resource.

As your infrastructure grows, common patterns can emerge in which you declare the same components in multiple templates. You can separate out these common components and create dedicated templates for them. Then use the resource in your template to reference other templates, creating nested stacks.

Nested stacks can themselves contain other nested stacks, resulting in a hierarchy of stacks, as in the diagram below. The root stack is the top-level stack to which all the nested stacks ultimately belong. In addition, each nested stack has an immediate parent stack. For the first level of nested stacks, the root stack is also the parent stack. in the diagram below, for example:

* Stack A is the root stack for all the other, nested, stacks in the hierarchy.
* For stack B, stack A is both the parent stack, as well as the root stack.
* For stack D, stack C is the parent stack; while for stack C, stack B is the parent stack.

![Main stack format](images/nested-stacks.png)

Using nested stacks to declare common components is considered a best practice.

Nested stack usually require inputs parameters provided by other stack outputs, i.e.

`VpcId: !GetAtt VPCStack.Outputs.VPCID`

Complexity may arise form this format, but it helps preserve the structure and understanding of the environment declaring objects or collection of resources that integrate and consume each other.  


## Location
* **Stack Name**: Name provided to the stack.
* **Environment**: Environment (development, staging, production).
* **QSS3BucketName**: Bucket name holding the templates.
* **QSS3KeyPrefix**: Folder name holding the templates.

## VPC
* **AvailabilityZones**: Specific availability zones to use.
* **NumberOfAZs**: Number of availability zones to be used by the subnets.
* **VPCCIDR**: Classless Inter-Domain Routing for IP allocation.
* **PrivateSubnet1CIDR**: Classless Inter-Domain Routing for IP allocation on private subnet 1.
* **PrivateSubnet2CIDR**: Classless Inter-Domain Routing for IP allocation on private subnet 2.
* **PrivateSubnet3CIDR**: Classless Inter-Domain Routing for IP allocation on private subnet 3.
* **PublicSubnet1CIDR**: Classless Inter-Domain Routing for IP allocation on public subnet 1.
* **PublicSubnet2CIDR**: Classless Inter-Domain Routing for IP allocation on public subnet 2.
* **PublicSubnet3CIDR**: Classless Inter-Domain Routing for IP allocation on public subnet 3.

## Security
* **KeyPairName**: KeyPair Name for EC2 Access
* **Certificate**: SSL Certificate for Public loadbalancer.

## Infrastructure
* **EcsInstanceType**: EC2 instance type for ECS cluster.

![Main stack format](images/mainstack.png)
