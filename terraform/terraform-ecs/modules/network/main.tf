#
# AWS VPC setup
#
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    Name = "${terraform.workspace}"
  }
}

#
# AWS Subnets setup
#
resource "aws_subnet" "public_subnets" {
  count                   = "${length(var.availability_zones)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  cidr_block              = "${cidrsubnet(var.cidr,ceil(log(length(var.availability_zones) * 2, 2)),count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${terraform.workspace}-Public-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = "${length(var.availability_zones)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  cidr_block              = "${cidrsubnet(var.cidr,ceil(log(length(var.availability_zones) * 2, 2)), length(var.availability_zones) + count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${terraform.workspace}-Private-${count.index}"
  }
}

#
# AWS IGW setup
#
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${terraform.workspace}-igw"
  }
}

#
# AWS Nat Gateway setyp
# Used for the private subnets
resource "aws_eip" "nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_gw.id}"
  subnet_id     = "${aws_subnet.public_subnets.0.id}"
}

#
# AWS Route Table setup
# Grant the VPC internet access on its main route table
# resource "aws_route" "public_gateway" {
#   route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = "${aws_internet_gateway.igw.id}"
# }

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${terraform.workspace}-Public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  tags {
    Name = "${terraform.workspace}-Private"
  }
}

resource "aws_route_table_association" "private_subnet" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "public_subnet" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
