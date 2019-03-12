resource "aws_cloudwatch_log_group" "logs_group" {
  name = "${var.environment}-${var.service_name}-service"
  retention_in_days = "365"
  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "TaskDefinitionRole-${var.service_name}-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "TaskDefinitionRole-${var.service_name}-${var.environment}-policy"
  role = "${aws_iam_role.ecs_task_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:*",
        "kms:*",
        "sts:*"
      ],
      "Resource": [
	       "*"
      ]
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "taskDefinition" {
  family = "${var.service_name}-${var.environment}-task"
  task_role_arn = "${aws_iam_role.ecs_task_role.arn}"
  container_definitions =<<DEFINITION
[
  {
    "name": "${var.service_name}-rails",
    "image": "${var.rails_ecr}:${var.rails_tag}",
    "cpu": ${var.rails_cpu},
    "memory": ${var.rails_mem},
    "essential": true,
    "environment": [
      {
        "name": "EnvironmentType",
        "value": "${var.environment}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.logs_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "rails"
        }
    }
  },
  {
    "name": "${var.service_name}-nginx",
    "image": "${var.nginx_ecr}:${var.nginx_tag}",
    "cpu": ${var.nginx_cpu},
    "memory": ${var.nginx_mem},
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.logs_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "nginx"
        }
    },
    "portMappings": [{
      "hostPort": 0,
      "protocol": "tcp",
      "containerPort": ${var.containerPort}
    }],
    "links": [
      "${var.service_name}-rails"
    ]
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "taskDefinitionSchedule" {
  family = "${var.service_name}-${var.environment}-schedule"
  task_role_arn = "${aws_iam_role.ecs_task_role.arn}"
  container_definitions =<<DEFINITION
[
  {
    "name": "schedule-rails",
    "image": "${var.rails_ecr}:${var.rails_tag}",
    "memoryReservation": 512,
    "essential": true,
    "environment": [
      {
        "name": "EnvironmentType",
        "value": "${var.environment}"
      }
    ],
    "command": [
        "bash,-c,nclouds/start_environment.sh;"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.logs_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "rails"
        }
    }
  }
]
DEFINITION
}

resource "aws_iam_role" "ecs_service_role" {
  name = "ServiceRole-${var.service_name}-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_policy" {
  role = "${aws_iam_role.ecs_service_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_ecs_service" "service" {
  name = "${var.service_name}"
  cluster = "${var.ecs-cluster}"
  iam_role = "${aws_iam_role.ecs_service_role.id}"
  task_definition = "${aws_ecs_task_definition.taskDefinition.arn}"
  desired_count = "${var.task_count}"
  deployment_minimum_healthy_percent = "100"
  deployment_maximum_percent = "200"
  health_check_grace_period_seconds = "60"

  load_balancer {
    target_group_arn = "${var.alb-tg-arn}"
    container_name = "${var.service_name}-nginx"
    container_port = "${var.containerPort}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_ecs_task_definition.taskDefinition"]
}

resource "aws_iam_role" "ecs_scalabletarget_role" {
  name = "ScalableTargetRole-${var.service_name}-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_scalabletarget_role_policy" {
  name = "ScalableTargetRole-${var.service_name}-${var.environment}-policy"
  role = "${aws_iam_role.ecs_scalabletarget_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "application-autoscaling:*",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:SetAlarmState",
        "cloudwatch:DeleteAlarms"
      ],
      "Resource": [
	       "*"
      ]
    }
  ]
}
EOF
}

resource "aws_appautoscaling_target" "service_scalable_target" {
  max_capacity       = "${var.task_count}"
  min_capacity       = "${var.task_count}"
  resource_id        = "service/${var.service_name}-${var.environment}/${var.service_name}"
  role_arn           = "${aws_iam_role.ecs_scalabletarget_role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.service"]
}

resource "aws_appautoscaling_policy" "service_cpu_up_policy" {
  name               = "CPUUtilization-step-up"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.service_scalable_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.service_scalable_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.service_scalable_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.service_scalable_target"]
}

resource "aws_appautoscaling_policy" "service_mem_up_policy" {
  name               = "MEMUtilization-step-up"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.service_scalable_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.service_scalable_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.service_scalable_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.service_scalable_target"]
}

resource "aws_appautoscaling_policy" "service_cpu_down_policy" {
  name               = "CPUUtilization-step-down"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.service_scalable_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.service_scalable_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.service_scalable_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.service_scalable_target"]
}

resource "aws_appautoscaling_policy" "service_mem_down_policy" {
  name               = "MEMUtilization-step-down"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.service_scalable_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.service_scalable_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.service_scalable_target.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.service_scalable_target"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_cpu_up" {
  alarm_name                = "${var.service_name}-${var.environment}CPUUtilizationUp"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "${var.cpu_up_eval_periods}"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "${var.cpu_up_period}"
  statistic                 = "Average"
  threshold                 = "${var.cpu_up_threshold}"
  alarm_description         = "This metric monitors ecs cpu utilization of service ${var.service_name} ${var.environment}"

  dimensions = {
    ClusterName = "${var.service_name}-${var.environment}"
    ServiceName = "${var.service_name}"
  }

  alarm_actions     = ["${aws_appautoscaling_policy.service_cpu_up_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_mem_up" {
  alarm_name                = "${var.service_name}-${var.environment}MEMUtilizationUp"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "${var.mem_up_eval_periods}"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "${var.mem_up_period}"
  statistic                 = "Average"
  threshold                 = "${var.mem_up_threshold}"
  alarm_description         = "This metric monitors ecs mem utilization of service ${var.service_name} ${var.environment}"

  dimensions = {
    ClusterName = "${var.service_name}-${var.environment}"
    ServiceName = "${var.service_name}"
  }

  alarm_actions     = ["${aws_appautoscaling_policy.service_mem_up_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_cpu_down" {
  alarm_name                = "${var.service_name}-${var.environment}CPUUtilizationDown"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "${var.cpu_down_eval_periods}"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "${var.cpu_down_period}"
  statistic                 = "Average"
  threshold                 = "${var.cpu_down_threshold}"
  alarm_description         = "This metric monitors ecs cpu utilization of service ${var.service_name} ${var.environment}"

  dimensions = {
    ClusterName = "${var.service_name}-${var.environment}"
    ServiceName = "${var.service_name}"
  }

  alarm_actions     = ["${aws_appautoscaling_policy.service_cpu_down_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_mem_down" {
  alarm_name                = "${var.service_name}-${var.environment}MEMUtilizationDown"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "${var.mem_down_eval_periods}"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "${var.mem_down_period}"
  statistic                 = "Average"
  threshold                 = "${var.mem_down_threshold}"
  alarm_description         = "This metric monitors ecs mem utilization of service ${var.service_name} ${var.environment}"

  dimensions = {
    ClusterName = "${var.service_name}-${var.environment}"
    ServiceName = "${var.service_name}"
  }

  alarm_actions     = ["${aws_appautoscaling_policy.service_mem_down_policy.arn}"]
}
