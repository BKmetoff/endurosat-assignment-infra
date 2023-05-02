locals {
  policy_name = "gh-actions-${var.github_actions.organization}-${var.github_actions.repository}"
  role_name   = "gh-actions-${var.github_actions.organization}-${var.github_actions.repository}"
}


resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# OIDC
resource "aws_iam_role" "github_actions" {
  name = local.role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.github.arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_actions.organization}/${var.github_actions.repository}:*"
          },
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# repo
data "aws_iam_policy_document" "github_actions" {
  count = length(var.environments)

  statement {
    resources = [
      aws_ecr_repository.repo[count.index].arn
    ]
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken", ]
    resources = ["*"]
  }

  # allow the role to update the ecs service as well.
  # this permission is used  in the CI pipelines
  # of the application repository.
  statement {
    resources = ["*"]
    actions   = ["ecs:UpdateService"]
  }
}

resource "aws_iam_policy" "github_actions" {
  count = length(var.environments)

  name        = "${local.policy_name}-${var.environments[count.index]}"
  policy      = data.aws_iam_policy_document.github_actions[count.index].json
  description = "Allow Github Actions to push to ECR from ${var.github_actions.organization}/${var.github_actions.repository}"
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  count = length(var.environments)

  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions[count.index].arn
}
