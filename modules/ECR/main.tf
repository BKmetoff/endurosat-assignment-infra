# Create one repository for each environment
resource "aws_ecr_repository" "repo" {
  count = length(var.environments)

  name                 = "${var.name}-${var.environments[count.index]}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.key[count.index].arn
  }

}

# KMS keys
resource "aws_kms_key" "key" {
  count       = length(var.environments)
  description = "KMS key for ECR repo ${var.name}-${var.environments[count.index]}"
}

# Use the same policy for all repos
data "aws_iam_policy_document" "allow_all" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_ecr_repository_policy" "repo_policy" {
  count = length(var.environments)

  repository = aws_ecr_repository.repo[count.index].name
  policy     = data.aws_iam_policy_document.allow_all.json
}

# remove untagged images
# keep only one image per repo
resource "aws_ecr_lifecycle_policy" "foopolicy" {
  count = length(var.environments)

  repository = aws_ecr_repository.repo[count.index].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only one image in the repo",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
