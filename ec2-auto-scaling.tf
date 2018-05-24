resource "aws_autoscaling_group" "asg_selenium" {
  name                      = "asg_selenium"
  launch_configuration      = "${aws_launch_configuration.launch-config_selenium.id}"
  vpc_zone_identifier       = ["${element(var.subnets, 0)}"]
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 400
  target_group_arns         = ["${aws_alb_target_group.alb-tg-selenium.id}"]

  tags = [
    {
      key                 = "Name"
      value               = "selenium-scale-group"
      propagate_at_launch = true
    },
  ]
}

resource "aws_autoscaling_policy" "asp_selenium-scale-up" {
  name                      = "asp_selenium-scale-up"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.asg_selenium.name}"
  estimated_instance_warmup = 60
  metric_aggregation_type   = "Average"
  policy_type               = "StepScaling"

  step_adjustment = {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 2
  }
}

resource "aws_cloudwatch_metric_alarm" "cw-alarm_selenium-scale-up" {
  alarm_name          = "cw-alarm_selenium-scale-up"
  alarm_description   = "O uso de CPU atingiu 70% no ultimo minuto"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Maximum"
  threshold           = 70
  period              = 60
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${aws_autoscaling_policy.asp_selenium-scale-up.arn}"]

  dimensions = {
    Name  = "ClusterName"
    Value = "${var.cluster-name}"
  }
}

resource "aws_autoscaling_policy" "asp_selenium-scale-down" {
  name                   = "asp_selenium-scale-down"
  adjustment_type        = "PercentChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.asg_selenium.name}"
  cooldown               = 120
  scaling_adjustment     = -50
}

resource "aws_cloudwatch_metric_alarm" "cw-alarm_selenium-scale-down" {
  alarm_name          = "cw-alarm_selenium-scale-down"
  alarm_description   = "O uso de CPU está abaixo de 50% nos últimos 10 minutos"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  comparison_operator = "LessThanThreshold"
  statistic           = "Maximum"
  threshold           = 50
  period              = 600
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${aws_autoscaling_policy.asp_selenium-scale-down.arn}"]

  dimensions = {
    Name  = "ClusterName"
    Value = "${var.cluster-name}"
  }
}
