data "aws_iam_policy_document" "iam-policy_ec2-selenium-assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam-policy_ecs-selenium-assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam-policy_selenium-ec2-doc" {
  statement {
    actions = [
      "ecs:*",
      "s3:*",
      "elasticloadbalancing:Describe*",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "iam-policy_selenium-ecs-doc" {
  statement {
    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "ec2:AuthorizeSecurityGroupIngress",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "iam_selenium-ec2-role" {
  name               = "iam_selenium-ec2-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.iam-policy_ec2-selenium-assume.json}"
}

resource "aws_iam_role_policy" "iam-policy_selenium-ec2" {
  name   = "integr8-selenium-ec2-policy"
  policy = "${data.aws_iam_policy_document.iam-policy_selenium-ec2-doc.json}"
  role   = "${aws_iam_role.iam_selenium-ec2-role.id}"
}

resource "aws_iam_role" "iam_selenium-ecs-role" {
  name               = "iam_selenium-ecs-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.iam-policy_ecs-selenium-assume.json}"
}

resource "aws_iam_role_policy" "iam-policy_selenium-ecs" {
  name   = "iam-policy_selenium-ecs"
  policy = "${data.aws_iam_policy_document.iam-policy_selenium-ecs-doc.json}"
  role   = "${aws_iam_role.iam_selenium-ecs-role.id}"
}
