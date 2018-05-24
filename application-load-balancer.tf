resource "aws_alb_target_group" "alb-tg-selenium" {
  name = "alb-tg-selenium"
  port = 8081

  health_check {
    path = "/"
  }

  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"
}

resource "aws_alb" "alb-selenium" {
  name            = "alb-selenium"
  subnets         = ["${var.subnets}"]
  security_groups = ["${aws_security_group.sg-alb_selenium.id}"]
}

resource "aws_alb_listener" "alb-ltn_selenium" {
  load_balancer_arn = "${aws_alb.alb-selenium.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb-tg-selenium.id}"
    type             = "forward"
  }

  depends_on = [
    "aws_alb_target_group.alb-tg-selenium",
    "aws_alb.alb-selenium",
  ]
}
