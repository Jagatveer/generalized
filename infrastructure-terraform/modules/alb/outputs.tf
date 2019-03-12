output "alb_url" {
  value = "${aws_alb.public-alb.dns_name}"
}

output "alb_zone" {
  value = "${aws_alb.public-alb.zone_id}"
}

output "alb_arn" {
  value = "${aws_alb.public-alb.arn}"
}

output "http_listener_arn" {
  value = "${aws_alb_listener.http_listener.arn}"
}

output "https_listener_arn" {
  value = "${aws_alb_listener.https_listener.arn}"

}

output "alb-sg" {
  value = "${aws_security_group.alb-sg.id}"
}

output "alb-tg" {
  value = "${aws_alb_target_group.https_target_group.id}"
}
