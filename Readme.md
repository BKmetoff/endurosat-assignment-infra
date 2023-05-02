# Endurosat assignment infrastructure

This repo contains Infrastructure as Code using [Terraform](https://www.terraform.io/) to support the deployment of "a simple web app" in the cloud space of [AWS](https://aws.amazon.com/).

## The "Why"-s and the "What"-s:

- ### The main Why-s:

  - **Why use Terraform?** - Terraform allows deploying, keeping track, and maintaining, cloud infrastructure and infrastructure resources.
  - **Why AWS?** - AWS offers a vast array of cloud infrastructure resources that supports deployment of applications. It's one of the most use cloud service providers. For the purpose of this exercise, AWS provides all the necessary resources, as well as resources that can be used on expanding the security, scalability, and flexibility of the project.

- ### The more in-depth Why-s:

  - **Why use [ECR](https://docs.aws.amazon.com/ecr/index.html)?** - Since AWS resources are used for the deployment-replated infrastructure, it makes sense to keep the entire deployment process "in-house". Therefore, it is preferable to use ECR instead of other container registries;

  - **Why use [ECS](https://docs.aws.amazon.com/ecs/index.html)?** - As AWS' own container management service, ECS allows managing running (clusters of) containers running in EC2 instances.

- **What about authentication?** - the configuration in this repository "opens the door" for spinning up cloud infrastructure in AWS using an OIDC token created in the `modules/ECR/github_actions.tf` manifest. The token allows a GitHub repository to communicate with AWS by assuming the identity of an AWS account. The token is then "exposed" as a AWS IAM role\* and consumed by the GH workflows in the [application repository](https://github.com/BKmetoff/endurosat-assignment) which, in turn, manage AWS resources using various GH actions.
- **What's the deployment flow?** - To enable the CI pipeline from the [application repository](https://github.com/BKmetoff/endurosat-assignment/) to run successfully, the infrastructure in this repository must be deployed _first_.
- **What could be improved?**
  - **Triggering deployments**- At the moment, new versions of the application are "re-deployed" in the ECS cluster by updating the ECS service in each cluster. This is done by a GH workflow in the app repo. The workflow is triggered in the pipeline for each environment, once a new docker image is pushed to ECR. A better, more elegant, and consistent way of triggering deployments is to use the [AWS EventBridge](https://docs.aws.amazon.com/eventbridge/index.html) service. Ideally, once a new image is pushed to ECR, and is scanned successfully, an event would be emitted by ECR and captured by an EventBridge Bus. Once having received the event, the Bus would trigger an update of the respective ECS service, thus, triggering it to pick up the newly uploaded image;

_\*) the arn of role **must** be hardcoded in the respective GH action and **must** be spelled in the same way, case sensitive._

---

## Prerequisites

1. Install `tfenv` at the latest version
2. Install Terraform version `1.2.3` with `tfenv install 1.2.3`
3. Configure AWS credentials and confirm access to remote state.

## Workflow

1. Clone the repo and `cd` into the folder;
2. Run `terraform init`
3. Run `terraform plan`\*
4. To create the necessary resources, run one of th following:

   - `terraform apply` and confirm with `yes` when prompted;
   - `terraform apply -auto-approve` to skip the prompt;

_\*) to save the output of `terraform plan`, run `terraform plan -out=plan.out`. To use the output, run `terraform apply "plan.out"`_

---

## Repo structure & concept

```
├── Readme.md
├── main.tf
├── outputs.tf
├── variables.tf
└── modules
    ├── ECR
    │   ├── Readme.md
    │   ├── github_actions.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── ECS
    │   ├── Readme.md
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── VPC
        ├── Readme.md
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

<p style="text-align: justify">
The infrastructure consists entirely of AWS resources - VPC, ECS, and ECR. Once a new docker image is pushed to the ECR repository by a <a href="https://github.com/BKmetoff/endurosat-assignment/blob/master/.github/workflows/build-and-push-dk-image.yaml">GitHub action</a> in the application repository,  <a href="https://github.com/BKmetoff/endurosat-assignment/blob/master/.github/workflows/update-ecs-cluster.yaml">another GH action workflow</a> will update the ECS service in the ECS cluster corresponding to the environment the new image is for. All environments (i.e. staging and/or production) can be accessed via the respective load balancer URL provided by the ECS module output.
</p>

<p style="text-align: justify">
The infrastructure is organized around the number of environments These environments can be set in the <code>environments</code> local variable in <code>/main.tf</code>. Once added there, the configuration will spin up an identical set of resources for each environment - one ECR repo to contain the docker images, one ECS cluster to deploy a service running these images in a task. The number of services can be adjusted via the <code>service_count</code> variable in <code>./modules/ECS</code>.
</p>

---

## Notes:

- the `resource_identifier` and `org` local variables in `/main.ft` _must_ be the same as the GitHub repository and they are _case sensitive!_ A mismatch would break the CI pipeline;
- to avoid hardcoding user/account identifiers, the AWS `account_id` is fetched using the [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) data resource provided by Terraform. This also provides an easier way to stand up the infrastructure;
- the GitHub actions in the [application repository](https://github.com/BKmetoff/endurosat-assignment/) authenticate in AWS via an [AWS OIDC token](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) that is created as part of the ECR module.
- the Terraform state (backend) is saved in a dedicated [AWS S3 bucket](https://developer.hashicorp.com/terraform/language/settings/backends/s3);

---

## Requirements

| Name                                                   | Version |
| ------------------------------------------------------ | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 3.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 3.76.1  |

## Modules

| Name                                         | Source        | Version |
| -------------------------------------------- | ------------- | ------- |
| <a name="module_ecr"></a> [ecr](#module_ecr) | ./modules/ECR | n/a     |
| <a name="module_ecs"></a> [ecs](#module_ecs) | ./modules/ECS | n/a     |
| <a name="module_vpc"></a> [vpc](#module_vpc) | ./modules/VPC | n/a     |

## Resources

| Name                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name                                                            | Description                       | Type     | Default       | Required |
| --------------------------------------------------------------- | --------------------------------- | -------- | ------------- | :------: |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region) | AWS region to create resources in | `string` | `"eu-west-1"` |    no    |

## Outputs

| Name                                                                                                     | Description                                 |
| -------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| <a name="output_load_balancer_addresses"></a> [load_balancer_addresses](#output_load_balancer_addresses) | The URLs of the ECS clusters load balancers |
