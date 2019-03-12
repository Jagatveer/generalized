output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnets_ids" {
  value = [
    "${aws_subnet.public-subnets.*.id}",
  ]
}

output "private_subnets_ids" {
  value = [
    "${aws_subnet.private-subnets.*.id}",
  ]
}

output "az_count" {
  value = "${var.az_count}"
}
