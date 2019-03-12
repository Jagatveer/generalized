resource "aws_cloudwatch_log_group" "delay_logs_group" {
  name = "${var.environment}-${var.service_name}-delayjob-logs"
  retention_in_days = "365"
  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_ecs_task_definition" "taskDefaultWorker" {
  family = "${var.service_name}-${var.environment}-DefaultWorker"
  task_role_arn = "${var.ecs_task_role}"
  container_definitions =<<DEFINITION
[
  {
    "name": "default-rails",
    "image": "${var.rails_ecr}:${var.rails_tag}",
    "cpu": ${var.delayed_cpu},
    "memory": ${var.delayed_mem},
    "essential": true,
    "environment": [
      {
        "name": "EnvironmentType",
        "value": "${var.environment}"
      },
      {
        "name": "DELAY_WORKER",
        "value": "default"
      }
    ],
    "command": [
        "./nclouds/start_delayjobs.sh"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.delay_logs_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "default-worker"
        }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "taskSerialWorker" {
  family = "${var.service_name}-${var.environment}-SerialCriticalWorker"
  task_role_arn = "${var.ecs_task_role}"
  container_definitions =<<DEFINITION
[
  {
    "name": "serial-rails",
    "image": "${var.rails_ecr}:${var.rails_tag}",
    "cpu": ${var.delayed_cpu},
    "memory": ${var.delayed_mem},
    "essential": true,
    "environment": [
      {
        "name": "EnvironmentType",
        "value": "${var.environment}"
      },
      {
        "name": "DELAY_WORKER",
        "value": "serial_critical"
      }
    ],
    "command": [
        "./nclouds/start_delayjobs.sh"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.delay_logs_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "serial-critical-worker"
        }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "taskBackfillWorker" {
  family = "${var.service_name}-${var.environment}-BackfillWorker"
  task_role_arn = "${var.ecs_task_role}"
  container_definitions =<<DEFINITION
[
  {
    "name": "backfill-rails",
    "image": "${var.rails_ecr}:${var.rails_tag}",
    "cpu": ${var.delayed_cpu},
    "memory": ${var.delayed_mem},
    "essential": true,
    "environment": [
      {
        "name": "EnvironmentType",
        "value": "${var.environment}"
      },
      {
        "name": "DELAY_WORKER",
        "value": "backfill"
      }
    ],
    "command": [
        "./nclouds/start_delayjobs.sh"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.delay_logs_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "backfill-worker"
        }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "delayjob-default-service" {
    name = "${var.service_name}-default-delayjob"
    cluster = "${var.ecs-cluster}"
    task_definition = "${aws_ecs_task_definition.taskDefaultWorker.arn}"
    desired_count = "1"
    deployment_minimum_healthy_percent = "100"
    deployment_maximum_percent = "200"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_ecs_service" "delayjob-serial-service" {
    name = "${var.service_name}-serial-critical-delayjob"
    cluster = "${var.ecs-cluster}"
    task_definition = "${aws_ecs_task_definition.taskSerialWorker.arn}"
    desired_count = "1"
    deployment_minimum_healthy_percent = "100"
    deployment_maximum_percent = "200"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_ecs_service" "delayjob-backfill-service" {
    name = "${var.service_name}-backfill-delayjob"
    cluster = "${var.ecs-cluster}"
    task_definition = "${aws_ecs_task_definition.taskBackfillWorker.arn}"
    desired_count = "1"
    deployment_minimum_healthy_percent = "100"
    deployment_maximum_percent = "200"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_appautoscaling_target" "default-delayjob_service_scalable_target" {
  max_capacity       = "1"
  min_capacity       = "1"
  resource_id        = "service/${var.ecs-cluster}/${var.service_name}-default-delayjob"
  role_arn           = "${var.ecs_scalabletarget_role}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.delayjob-default-service"]
}

resource "aws_appautoscaling_target" "serial-delayjob_service_scalable_target" {
  max_capacity       = "1"
  min_capacity       = "1"
  resource_id        = "service/${var.ecs-cluster}/${var.service_name}-serial-critical-delayjob"
  role_arn           = "${var.ecs_scalabletarget_role}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.delayjob-serial-service"]
}

resource "aws_appautoscaling_target" "backfill-delayjob_service_scalable_target" {
  max_capacity       = "1"
  min_capacity       = "1"
  resource_id        = "service/${var.ecs-cluster}/${var.service_name}-backfill-delayjob"
  role_arn           = "${var.ecs_scalabletarget_role}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.delayjob-backfill-service"]
}
