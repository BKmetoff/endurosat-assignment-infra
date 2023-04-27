output "ecr_arn" {
  description = "ARN of the ECR"
  value       = module.aws_ecr_repository.arn
}

output "ecr_url" {
  description = "Repository URL"
  value       = module.aws_ecr_repository.url

}

output "ecr_role" {
  description = "The GitHub actions role"
  value       = module.aws_ecr_repository.role
}
