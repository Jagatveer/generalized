# Database

* [RDS](#rds)

## RDS
Amazon Relational Database Service (Amazon RDS) makes it easy to set up, operate, and scale a relational database in the cloud. It provides cost-efficient and resizable capacity while automating time-consuming administration tasks such as hardware provisioning, database setup, patching and backups. It frees you to focus on your applications so you can give them the fast performance, high availability, security and compatibility they need.

Amazon RDS is available on several database instance types - optimized for memory, performance or I/O - and provides you with six familiar database engines to choose from, including Amazon Aurora, PostgreSQL, MySQL, MariaDB, Oracle, and Microsoft SQL Server. You can use the AWS Database Migration Service to easily migrate or replicate your existing databases to Amazon RDS.
**This template is invoked from `master.yml` file.**

* **AllocatedStorage**: Port Number
* **CreateReadReplica**: Subnets where the LB is able to listen.
* **DBInstanceClass**: Port where serivce is listening.
* **DBName**: Subnets where the LB is able to listen.
* **DBInstanceIdentifier**: VPC ID.
* **KmsKeyId**: SSL Certificate.
* **MasterUsername**: Subnets where the LB is able to listen.
* **MasterUserPassword**: VPC ID.
* **MultiAZ**: Port where serivce is listening.
* **RDSEndpoint**: SSL Certificate.
* **StorageEncrypted**: Port Number
* **VPCSubnetsIds**: Port where serivce is listening.
* **VpcId**: Port Number
* **VPCPrivateSG**: SSL Certificate.
