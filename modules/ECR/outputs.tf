output "arn" {
  description = "ARN of the ECR"
  value       = aws_ecr_repository.repo.arn
}

output "url" {
  description = "Repository URL"
  value       = aws_ecr_repository.repo.repository_url
}

output "role_arn" {
  description = "The ARN of the GH role"
  value       = aws_iam_role.github_actions.arn
}
