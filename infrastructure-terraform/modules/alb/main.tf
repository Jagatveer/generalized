resource "aws_alb" "public-alb" {
  lifecycle { create_before_destroy = true }
  name = "${var.environment}-public-alb"
  subnets = [ "${var.subnet_ids}" ]
  security_groups = [ "${aws_security_group.alb-sg.id}" ]
}

resource "aws_security_group" "alb-sg" {
    name = "${var.environment}-alb-sg"
    vpc_id = "${var.vpc_id}"
    description = "${var.environment}-alb-sg"

    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Redirect http requests to https */
resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = "${aws_alb.public-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = ["aws_alb.public-alb"]
}

resource "aws_alb_target_group" "https_target_group" {
  name                 = "${var.environment}-https-tg"
  port                 = "${var.containerPort}"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"

  deregistration_delay = 60

  health_check {
    interval            = "30"
    timeout             = "15"
    unhealthy_threshold = "10"
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200,301"
  }

  depends_on = ["aws_alb.public-alb"]
}

resource "aws_alb_listener" "https_listener" {
  load_balancer_arn = "${aws_alb.public-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.https_target_group.arn}"
  }

  depends_on = ["aws_alb.public-alb"]
}
