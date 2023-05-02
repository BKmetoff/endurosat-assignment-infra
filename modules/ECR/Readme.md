## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.foopolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.repo_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy_document.allow_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environments"></a> [environments](#input\_environments) | The names of the repository environments, i.e. 'production','staging', etc. | `list(string)` | n/a | yes |
| <a name="input_github_actions"></a> [github\_actions](#input\_github\_actions) | The identifier of the GitHub repository | <pre>object({<br>    organization = string<br>    repository   = string<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of this repository (should match the name of the GH repo) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gh_role_arn"></a> [gh\_role\_arn](#output\_gh\_role\_arn) | The ARN of the GH role |
| <a name="output_repo_arns"></a> [repo\_arns](#output\_repo\_arns) | ARN of the ECRs |
| <a name="output_repo_urls"></a> [repo\_urls](#output\_repo\_urls) | Repository URL |
