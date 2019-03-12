output "ecs-cluster-id" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "instance-sg" {
  value = "${aws_security_group.instance-sg.id}"
}

output "ecs-iam-role" {
  value = "${aws_iam_role.ecs_instance_role.arn}"
}
