resource "aws_security_group" "sg_efs-selenium" {
  name        = "sg_efs-selenium-ingress"
  description = "Permite o trafico do EC2 para o EFS"
  vpc_id      = "${var.vpc-id}"

  tags {
    Name = "sg_efs-selenium"
  }
}

resource "aws_security_group_rule" "sgr_efs-selenium-ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg_efs-selenium.id}"
  source_security_group_id = "${aws_security_group.sg-ec2_selenium.id}"
}

resource "aws_security_group" "sg-alb_selenium" {
  name        = "sg_alb_selenium"
  description = "Permite o trafego para no ALB"
  vpc_id      = "${var.vpc-id}"

  tags {
    Name = "sg-alb_selenium"
  }
}

resource "aws_security_group_rule" "sgr-alb_selenium-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg-alb_selenium.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sgr-alb_selenium-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.sg-alb_selenium.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "sg-ec2_selenium" {
  name        = "sg_ec2_selenium"
  description = "Permite o trafego para ao EC2"
  vpc_id      = "${var.vpc-id}"

  tags {
    Name = "sg-ec2_selenium"
  }
}

resource "aws_security_group_rule" "sgr-ec2_selenium-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg-ec2_selenium.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sgr-ec2_selenium-http" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.sg-ec2_selenium.id}"
  source_security_group_id = "${aws_security_group.sg-alb_selenium.id}"
}

resource "aws_security_group_rule" "srg-ec2_selenium-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg-ec2_selenium.id}"
}
