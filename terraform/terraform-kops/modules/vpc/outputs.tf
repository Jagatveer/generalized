output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}
output "public_subnets_ids" {
  value = [
    "${aws_subnet.public_subnets.*.id}",
  ]
}

output "public_subnets_cidrs" {
  value = [
    "${aws_subnet.public_subnets.*.cidr_block}",
  ]
}

output "public_subnets_azs" {
  value = [
    "${aws_subnet.public_subnets.*.availability_zone}",
  ]
}

output "private_subnets_ids" {
  value = [
    "${aws_subnet.private_subnets.*.id}",
  ]
}

output "private_subnets_cidrs" {
  value = [
    "${aws_subnet.private_subnets.*.cidr_block}",
  ]
}

output "private_subnets_azs" {
  value = [
    "${aws_subnet.private_subnets.*.availability_zone}",
  ]
}

output "private_route_table" {
  value = "${aws_route_table.private_route_table.0.id}"
}
output "public_route_table" {
  value = "${aws_route_table.public_route_table.0.id}"
}
