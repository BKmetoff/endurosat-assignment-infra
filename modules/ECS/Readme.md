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
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_security_group.task_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The ID of the AWS account | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources in | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port of the container | `number` | n/a | yes |
| <a name="input_container_resources"></a> [container\_resources](#input\_container\_resources) | The CPU and memory to be allocated for the container | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | n/a | yes |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | The name and tag of the docker image | <pre>object({<br>    name = string<br>    tag  = string<br>  })</pre> | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | The names of the repository environments, i.e. 'production','staging', etc. | `list(string)` | n/a | yes |
| <a name="input_load_balancer_security_group_id"></a> [load\_balancer\_security\_group\_id](#input\_load\_balancer\_security\_group\_id) | The ID of the load balancer security group | `string` | n/a | yes |
| <a name="input_load_balancer_target_group_ids"></a> [load\_balancer\_target\_group\_ids](#input\_load\_balancer\_target\_group\_ids) | A list of the IDs of the load balancers target groups | `list(string)` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The IDs of the private subnets in the VPC | `list(string)` | n/a | yes |
| <a name="input_service_count"></a> [service\_count](#input\_service\_count) | How many ECS services should be created | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_cluster_arns"></a> [ecr\_cluster\_arns](#output\_ecr\_cluster\_arns) | The ARNs of the ECS clusters |
| <a name="output_ecs_task_definition_arns"></a> [ecs\_task\_definition\_arns](#output\_ecs\_task\_definition\_arns) | The ARNs of the task definitions |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | ARN of IAM role used for ELB |
| <a name="output_id"></a> [id](#output\_id) | The ID of the ECS service |
