resource "aws_ecs_cluster" "ecs-cluster_selenium" {
  name = "${var.cluster-name}"
}

resource "aws_appautoscaling_target" "ecs-as-target_selenium" {
  max_capacity       = 1
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster_selenium.name}/${aws_ecs_service.ecs-service_selenium.name}"
  role_arn           = "${aws_iam_role.iam_selenium-ecs-role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_ecs_task_definition" "ecs-tf_selenium" {
  family                = "selenium-node"
  container_definitions = "${file("${path.module}/custom/task-definition/selenium.json")}"
  network_mode          = "bridge"
}

resource "aws_ecs_service" "ecs-service_selenium" {
  name            = "selenium-service"
  cluster         = "${aws_ecs_cluster.ecs-cluster_selenium.arn}"
  task_definition = "${aws_ecs_task_definition.ecs-tf_selenium.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.iam_selenium-ecs-role.id}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb-tg-selenium.id}"
    container_name   = "selenium-hub-node"
    container_port   = 4444
  }

  depends_on = [
    "aws_alb_target_group.alb-tg-selenium",
    "aws_alb.alb-selenium",
  ]
}
