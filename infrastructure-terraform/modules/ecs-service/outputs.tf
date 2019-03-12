output "ecs_task_role" {
  value = "${aws_iam_role.ecs_task_role.arn}"
}
output "ecs_service_role" {
  value = "${aws_iam_role.ecs_service_role.arn}"
}
output "logs_group_name" {
  value = "${aws_cloudwatch_log_group.logs_group.name}"
}
output "ecs_scalabletarget_role" {
  value = "${aws_iam_role.ecs_scalabletarget_role.arn}"
}
