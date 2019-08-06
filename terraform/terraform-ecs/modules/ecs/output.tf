output "ecs" {
  value = "${aws_ecs_cluster.ecs-cluster.arn}"
}

output "autoscaling" {
  value = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
}
