resource "aws_efs_file_system" "efs" {
  creation_token = "${var.environment}_${var.cluster_name}"

  tags {
    Name = "${var.environment}_${var.cluster_name}"
  }
}

resource "aws_efs_mount_target" "efs" {
  count           = "${var.private_subnet_count}"
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${element(var.private_subnets, count.index)}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_security_group" "efs" {
  name        = "${var.environment}-${var.cluster_name}-efs"
  description = "EFS"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = "2049"
    to_port         = "2049"
    protocol        = "tcp"
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}
