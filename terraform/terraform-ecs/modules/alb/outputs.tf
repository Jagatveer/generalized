output "alb_url" {
  value = "${aws_alb.main.dns_name}"
}

output "alb_zone" {
  value = "${aws_alb.main.zone_id}"
}

output "alb_arn" {
  value = "${aws_alb.main.arn}"
}

output "http_listener_arn" {
  value = "${aws_alb_listener.http_listener.arn}"
}
# output "https_listener_arn" {
#   value = "${aws_alb_listener.https_listener.arn}"
# }
output "alb_sg" {
  value = "${aws_security_group.lb.id}"
}
