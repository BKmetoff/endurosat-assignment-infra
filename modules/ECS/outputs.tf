output "iam_role" {
  value       = aws_ecs_service.service[*].iam_role
  description = "ARN of IAM role used for ELB"
}

output "id" {
  value       = aws_ecs_service.service[*].id
  description = "The ID of the ECS service"
}

output "ecs_task_definition_arns" {
  value       = aws_ecs_task_definition.task[*].arn
  description = "The ARNs of the task definitions"
}

output "ecr_cluster_arns" {
  value       = aws_ecs_cluster.cluster[*].arn
  description = "The ARNs of the ECS clusters"
}
