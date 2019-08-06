resource "aws_security_group" "lb" {
  name        = "${var.lb_name}-sg"
  description = "controls access to the ALB"
  vpc_id      = "${var.vpc_id}"

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

resource "aws_alb" "main" {
  name            = "${var.lb_name}"
  internal        = "${var.lb_is_internal}"
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.lb.id}"]
}


resource "aws_alb_target_group" "default_target" {
  name        = "${var.lb_name}-default"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"
}

resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.default_target.id}"
    type             = "forward"
  }
}

# resource "aws_alb_listener" "https_listener" {
#   load_balancer_arn = "${aws_alb.main.id}"
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
#   certificate_arn   = "${var.alb_certificate_arn}"
#   default_action {
#     target_group_arn = "${aws_alb_target_group.default_target.id}"
#     type             = "forward"
#   }
# }
