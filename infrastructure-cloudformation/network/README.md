# Network

* [VPC](#vpc)

## VPC
Amazon Virtual Private Cloud (Amazon VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways. You can use both IPv4 and IPv6 in your VPC for secure and easy access to resources and applications.

**This template is invoked from `main.yml` file.**

* The VPC.
* 3 Private subnets in 3 availability zones.
* 3 Public subnets in 3 availability zones.
* 1 Internet gateway and its attachment.
* 3 Nat gateways and its attachment.
* 6 Route tables and associations.
* 3 Elastic IPs for the NAT gateways.
* Necessary access control list for each subnet.

![VPC Diagram](../images/VPC.png)
