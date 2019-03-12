resource "aws_ecs_cluster" "cluster" {
  name = "${var.service_name}-${var.environment}"
}

/* IAM Profile for ecs instance */
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.environment}_ecs_instance_profile"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.environment}_ecs_instance_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name = "${var.environment}_ecs_instance_role_policy"
  role = "${aws_iam_role.ecs_instance_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
      	"ecr:*",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeAutoScalingGroups",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
      	"cloudtrail:LookupEvents",
      	"ec2:AuthorizeSecurityGroupIngress",
      	"ec2:Describe*",
      	"elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      	"elasticloadbalancing:DeregisterTargets",
      	"elasticloadbalancing:Describe*",
      	"elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      	"elasticloadbalancing:RegisterTargets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_1" {
  role = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_2" {
  role = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_3" {
  role = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

resource "aws_security_group" "instance-sg" {
  name = "${var.environment}-instance-sg"
  vpc_id = "${var.vpc_id}"
  description = "Security group for instances"

  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Allow incoming requests from ELB and peers only */
resource "aws_security_group_rule" "allow_all_from_instance" {
  type = "ingress"
  from_port = 3000
  to_port = 3000
  protocol = "-1"

  security_group_id = "${aws_security_group.instance-sg.id}"
  source_security_group_id = "${var.alb-sg}"
}

resource "aws_security_group_rule" "allow_all_from_peers" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"

  security_group_id = "${aws_security_group.instance-sg.id}"
  source_security_group_id = "${aws_security_group.instance-sg.id}"
}

resource "aws_launch_configuration" "lc_on_demand" {
  name = "${var.environment}_lc"
  instance_type = "${var.instance_type}"
  image_id = "${data.aws_ami.ecs.image_id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  user_data = "${data.template_file.user_data.rendered}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.instance-sg.id}"]
  associate_public_ip_address = false
  ebs_optimized = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name = "${var.environment}_asg"
  max_size = "${var.ecs_max_size}"
  min_size = "${var.ecs_min_size}"
  desired_capacity = "${var.desired_capacity}"
  default_cooldown = 30
  health_check_grace_period = 30
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.lc_on_demand.name}"
  vpc_zone_identifier = [ "${var.private_subnet_ids}" ]

  tag {
    key = "Name"
    value = "${var.environment}-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "ecs_scale_up" {
  name                   = "${var.environment}_ECSUpStepScalePolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = "${aws_autoscaling_group.auto_scaling_group.name}"
}

resource "aws_autoscaling_policy" "ecs_scale_down" {
  name                   = "${var.environment}_ECSDownStepScalePolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = "${aws_autoscaling_group.auto_scaling_group.name}"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_up" {
  alarm_name                = "${var.environment}ECSCPUReservationUp"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUReservation"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "This metric monitors ecs cpu reservation of cluster ${var.environment}"

  dimensions = {
    ClusterName = "${var.service_name}-${var.environment}"
  }

  alarm_actions     = ["${aws_autoscaling_policy.ecs_scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_down" {
  alarm_name                = "${var.environment}ECSCPUReservationDown"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUReservation"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "45"
  alarm_description         = "This metric monitors ecs cpu reservation of cluster ${var.environment}"

  dimensions = {
    ClusterName = "${var.service_name}-${var.environment}"
  }

  alarm_actions     = ["${aws_autoscaling_policy.ecs_scale_down.arn}"]
}

data "template_file" "user_data" {
    template = "${file("${path.module}/user_data.tpl")}"
    vars {
        ecs_cluster = "${aws_ecs_cluster.cluster.id}"
    }
}
