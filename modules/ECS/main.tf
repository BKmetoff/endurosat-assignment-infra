locals {
  docker_image              = "${var.docker_image.name}-${var.environment}:${var.docker_image.tag}"
  docker_image_full_address = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.docker_image}"
  deployment                = "${var.docker_image.name}-${var.environment}"
}

resource "aws_ecs_cluster" "cluster" {
  name = local.deployment
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}
resource "aws_ecs_task_definition" "task" {
  family                   = local.deployment
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_resources.cpu
  memory                   = var.container_resources.memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "${local.docker_image_full_address}",
    "cpu": ${var.container_resources.cpu},
    "memory": ${var.container_resources.memory},
    "name": "${local.deployment}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ]
  }
]
DEFINITION
}


resource "aws_security_group" "task_sg" {
  name   = "${local.deployment}-task-security-group"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [var.load_balancer_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_service" "service" {
  name            = "${local.deployment}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.task_sg.id]
    subnets         = [for id in var.private_subnet_ids : id]
  }

  desired_count = var.service_count

  load_balancer {
    target_group_arn = var.load_balancer_target_group_id
    container_name   = local.deployment
    container_port   = var.container_port
  }
}
