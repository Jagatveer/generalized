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

output "private_subnets_ids" {
  value = [
    "${aws_subnet.private_subnets.*.id}",
  ]
}

output "rds_subnet_group" {
  value = ["${aws_db_subnet_group.rds.*.name}"]
}

output "es_subnet_group" {
  value = "${aws_elasticache_subnet_group.elasticache.0.name}"
}

output "private_route_table" {
  value = "${aws_route_table.private_route_table.0.id}"
}
output "public_route_table" {
  value = "${aws_route_table.public_route_table.0.id}"
}
