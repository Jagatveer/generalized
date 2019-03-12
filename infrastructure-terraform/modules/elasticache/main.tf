resource "aws_security_group" "redis" {
  name   = "${var.service_name}-${var.environment}-redis-sg"
  vpc_id = "${var.vpc_id}"
  description = "Redis security group"
  ingress {
    from_port   = "6379"
    to_port     = "6379"
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${var.ecs_security_group}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name        = "${var.service_name}-${var.environment}-redis-subnetgroup"
  subnet_ids  = ["${var.private_subnet_ids}"]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.service_name}-${var.environment}"
  engine               = "redis"
  engine_version       = "${var.elasticache_engine_version}"
  maintenance_window   = "${var.maintenance_window}"
  node_type            = "${var.elasticache_instance_type}"
  num_cache_nodes      = "1"
  parameter_group_name = "${var.parameter_group_name}"
  port                 = "6379"
  subnet_group_name    = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids   = ["${aws_security_group.redis.id}"]
  tags {
    Name          = "${var.service_name}-${var.environment}-redis"
    environment   = "${var.environment}"
  }
}
