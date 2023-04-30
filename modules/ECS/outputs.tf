output "iam_role" {
  value       = aws_ecs_service.service.iam_role
  description = "ARN of IAM role used for ELB"
}

output "id" {
  value       = aws_ecs_service.service.id
  description = "The ID of the ECS service"
}

output "arn" {
  value       = aws_ecs_task_definition.task.arn
  description = "The ARN of the task definition"
}
