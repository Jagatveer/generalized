######
# ECS cluster
######
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.cluster}-${terraform.workspace}"
}

######
# Autoscaling Group
######

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                  = "siq-${terraform.workspace}"
  max_size              = "${var.max_size}"
  min_size              = "${var.min_size}"
  desired_capacity      = "${var.desired_capacity}"
  vpc_zone_identifier   = ["${var.private_subnet_ids}"]
  launch_configuration  = "${aws_launch_configuration.default.name}"
  protect_from_scale_in = true

  tag {
    key                 = "Name"
    value               = "transition-${terraform.workspace}"
    propagate_at_launch = true
  }
}

######
# Launch Configuration
######

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    cluster_name = "${var.cluster}-${terraform.workspace}"
    env          = "${terraform.workspace}"
    region       = "${var.region}"
    asg          = "siq-${terraform.workspace}"
    storage      = "${var.storage}"
  }
}

data "aws_ami" "latest_ecs" {
  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "default" {
  name_prefix          = "siq-${terraform.workspace}"
  image_id             = "${data.aws_ami.latest_ecs.image_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.instance.id}"]
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  key_name             = "${var.key_name}"

  root_block_device {
    volume_type           = "standard"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "gp2"
    volume_size           = "${var.storage}"
    delete_on_termination = true
  }
  # aws_launch_configuration can not be modified.
  # Therefore we use create_before_destroy so that a new modified aws_launch_configuration can be created
  # before the old one get's destroyed. That's why we use name_prefix instead of name.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name   = "${terraform.workspace}-${var.cluster}-sg"
  vpc_id = "${var.vpc_id}"



  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "${terraform.workspace}-${var.cluster}-sg"
  }
}

######
# instance profile
######

resource "aws_iam_role_policy_attachment" "attach" {
  role       = "${aws_iam_role.instance_role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "ecs-instance-${terraform.workspace}"
  role = "${aws_iam_role.instance_role.id}"
}

resource "aws_iam_policy" "policy" {
  name = "ecs-policy-${terraform.workspace}"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
        "ecs:*",
        "ecr:*",
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "ec2:*",
        "sns:Publish",
        "cloudformation:*",
        "sqs:*",
        "autoscaling:SetInstanceProtection",
        "s3:*"
      ],
      "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role" "instance_role" {
  name = "ecs-${terraform.workspace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TrustEC2",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
