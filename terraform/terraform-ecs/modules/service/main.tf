resource "aws_alb_target_group" "app" {
  name        = "${var.app_name}-${var.environment}"
  port        = "${var.app_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  # target_type = "awsvpc"
  health_check {
    healthy_threshold   = 2
    interval            = 30
    path                = "${var.health_check}"
    timeout             = 10
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "service" {
  listener_arn = "${var.listener}"
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.app.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}


resource "aws_security_group" "ecs_tasks" {
  name        = "${terraform.workspace}-${var.app_name}-task"
  description = "allow outbound"
  vpc_id      = "${var.vpc_id}"

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.app_name}-${terraform.workspace}"
}

resource "aws_ecs_task_definition" "app" {
  family             = "${var.app_name}-${terraform.workspace}"
  task_role_arn      = "${aws_iam_role.task_role.id}"
  execution_role_arn = "${aws_iam_role.task_role.id}"

  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.cpu},
    "image": "${var.app_image}",
    "memory": ${var.memory},
    "portMappings": [
      {
        "containerPort": ${var.app_port}
      },
      {
        "containerPort": 5000
      }
    ],
    "mountPoints":[
      {
        "containerPath": "/var/run/docker.sock",
        "sourceVolume": "docker-socket"
      }
    ],
    "name": "${var.app_name}-${terraform.workspace}",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.log_group.id}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "${var.app_name}"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-${terraform.workspace}"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "${var.app_count}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    container_name   = "${var.app_name}-${var.environment}"
    container_port   = "${var.app_port}"
  }
}

resource "aws_iam_role" "task_role" {
  name = "task-${var.app_name}-${terraform.workspace}-${var.region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy" {
  name = "task-${var.app_name}-${terraform.workspace}-${var.region}"
  role = "${aws_iam_role.task_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "cloudformation:*",
        "s3:*",
        "kms:*",
        "logs:*",
        "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
