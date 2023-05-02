output "repo_arns" {
  description = "ARN of the ECRs"
  value       = aws_ecr_repository.repo[*].arn
}

output "repo_urls" {
  description = "Repository URL"
  value       = aws_ecr_repository.repo[0].repository_url
}

output "gh_role_arn" {
  description = "The ARN of the GH role"
  value       = aws_iam_role.github_actions.arn
}
