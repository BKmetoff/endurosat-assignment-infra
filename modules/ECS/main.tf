locals {
  repo_address = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

resource "aws_ecs_cluster" "cluster" {
  count = length(var.environments)

  name = "${var.docker_image.name}-${var.environments[count.index]}"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# use this resource to always pull the latest image using the image digest.
# https://github.com/hashicorp/terraform-provider-aws/issues/13528#issuecomment-797631866
# data "aws_ecr_image" "app" {
#   repository_name = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.deployment}"
#   image_tag       = var.docker_image.tag
# }

resource "aws_ecs_task_definition" "task" {
  count = length(var.environments)

  family                   = "${var.docker_image.name}-${var.environments[count.index]}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_resources.cpu
  memory                   = var.container_resources.memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  # "image": "${local.docker_image_full_address}@${data.aws_ecr_image.app.image_digest}",
  # "image": "${local.docker_image_full_address}",
  container_definitions = <<DEFINITION
[
  {
    "image": "${local.repo_address}/${var.docker_image.name}-${var.environments[count.index]}:${var.docker_image.tag}",
    "cpu": ${var.container_resources.cpu},
    "memory": ${var.container_resources.memory},
    "name": "${var.docker_image.name}-${var.environments[count.index]}",
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
  count = length(var.environments)

  name   = "${var.docker_image.name}-${var.environments[count.index]}-task-security-group"
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
  count = length(var.environments)

  name            = "${var.docker_image.name}-${var.environments[count.index]}-service"
  cluster         = aws_ecs_cluster.cluster[count.index].id
  task_definition = aws_ecs_task_definition.task[count.index].family
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.task_sg[count.index].id]
    subnets         = [for id in var.private_subnet_ids : id]
  }

  desired_count = var.service_count

  load_balancer {
    target_group_arn = var.load_balancer_target_group_ids[count.index]
    container_name   = "${var.docker_image.name}-${var.environments[count.index]}"
    container_port   = var.container_port
  }
}
