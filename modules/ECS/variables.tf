variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
}

variable "docker_image" {
  description = "The name and tag of the docker image"
  type = object({
    name = string
    tag  = string
  })
}

variable "container_resources" {
  description = "The CPU and memory to be allocated for the container"
  type = object({
    cpu    = number
    memory = number
  })
}

variable "container_port" {
  description = "The port of the container"
  type = number
}

variable "account_id" {
  description = "The ID of the AWS account"
  type        = string
}

variable "service_count" {
  description = "How many ECS services should be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets in the VPC"
  type        = list(string)
}

variable "load_balancer_target_group_id" {
  description = "The ID of the load balancer target group"
  type        = string
}

variable "load_balancer_security_group_id" {
  description = "The ID of the load balancer security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
