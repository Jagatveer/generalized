/* Create a VPC */

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc["cidr"]}"
  enable_dns_support = "${var.vpc["dns_hostnames"]}"
  enable_dns_hostnames = "${var.vpc["dns_support"]}"
  instance_tenancy     = "${var.vpc["tenancy"]}"

  tags {
    Name = "${var.environment}-VPC"
  }
}

/* For better availability, we will create our VPC in 3 different availability zones, with 3 private and 3 public subnets */
resource "aws_subnet" "public-subnets" {
  count = "${length(keys(var.public_subnets))}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${element(values(var.public_subnets), count.index)}"
  availability_zone = "${element(keys(var.public_subnets), count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.environment} Public-${count.index + 1}"
  }
}

resource "aws_subnet" "private-subnets" {
  count                   = "${length(keys(var.private_subnets))}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${element(keys(var.private_subnets), count.index)}"
  cidr_block              = "${element(values(var.private_subnets), count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.environment} Private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-igw"
  }
}

/* create Elastic IPs for NAT Gateways */
resource "aws_eip" "eips" {
  count = "${var.az_count}"
  vpc = true
}

/* * AWS NAT Gateway Setup for Private Subnets * */

resource "aws_nat_gateway" "nat-gws" {
  count = "${var.az_count}"
  allocation_id = "${element(aws_eip.eips.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public-subnets.*.id, count.index)}"

  depends_on = ["aws_eip.eips"]

  tags {
    Name = "${var.environment}-nat-gws-${count.index + 1}"
  }
}

/* * AWS Route Table setup
*    Grant the VPC internet access on its main route table
* */
resource "aws_route" "public_route" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

resource "aws_route_table" "private-route" {
  count = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.nat-gws.*.id, count.index)}"
  }

  tags {
    Name = "${var.environment} Private rt ${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_subnet" {
  count          = "${length(keys(var.private_subnets))}"
  subnet_id      = "${element(aws_subnet.private-subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private-route.*.id, count.index)}"
}
