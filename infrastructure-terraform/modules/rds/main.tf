resource "aws_security_group" "db-sg" {
    name = "${var.environment}-db-sg"
    vpc_id = "${var.vpc_id}"
    description = "Security group for RDS"

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

/* Allow incoming requests from EC2 only */
resource "aws_security_group_rule" "allow_all_from_instances" {
    type = "ingress"
    from_port = 5432
    to_port = 5432
    protocol = "-1"

    security_group_id = "${aws_security_group.db-sg.id}"
    source_security_group_id = "${var.instance-sg}"
}

resource "aws_db_subnet_group" "db_subg" {
  name       = "${var.database["identifier"]}-sg"
  subnet_ids = ["${var.private_subnet_ids}"]

  tags {
    Name = "${var.database["identifier"]}-sg"
  }
}

resource "aws_db_instance" "db" {
  identifier                  = "${var.database["identifier"]}"
  allocated_storage           = "${var.database["allocated_storage"]}"
  storage_type                = "${var.database["storage_type"]}"
  engine                      = "${var.database["engine"]}"
  engine_version              = "${var.database["engine_version"]}"
  instance_class              = "${var.database["instance_class"]}"
  multi_az                    = "${var.database["multi_az"]}"
  kms_key_id                  = "${var.database["kms_key_id"]}"
  username                    = "${var.database["db_user"]}"
  password                    = "${var.database["db_password"]}"
  storage_encrypted           = "${var.database["storage_encrypted"]}"
  vpc_security_group_ids      = ["${aws_security_group.db-sg.id}"]
  db_subnet_group_name        = "${aws_db_subnet_group.db_subg.name}"
  backup_retention_period     = "${var.database["backup_retention_period"]}"
  allow_major_version_upgrade = true
  skip_final_snapshot         = true
}
