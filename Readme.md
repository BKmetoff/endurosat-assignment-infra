# Endurosat assignment infrastructure

This repo contains Infrastructure as Code to support the deployment of "a simple web app", as part of the interview process.

To enable the CI pipeline from the [application repository](https://github.com/BKmetoff/endurosat-assignment/) to run successfully, the infrastructure in this repository must be deployed _first_.

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
├── main.tf
├── outputs.tf
├── variables.tf
└── modules
    ├── ECR
    │   ├── github_actions.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── ECS
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── VPC
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

<p style="text-align: justify">
The infrastructure consists entirely of AWS resources - VPC, ECS, and ECR. Once a new docker image is pushed to the ECR repository by the <a href="https://github.com/BKmetoff/endurosat-assignment/blob/master/.github/workflows/build-and-push-dk-image.yaml">GitHub action</a> in the application repository, it will be picked up by ECS and deployed via the task definition. The deployed application can be accessed via the URL provided by the ECS load balancer as an output of the ECS module, propagating to the main module.
</p>

---

## Notes:

- to avoid hardcoding user/account identifiers, the AWS `account_id` is fetched using the [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) data resource provided by Terraform. This also provides an easier way to stand up the infrastructure;
- the GitHub actions in the [application repository](https://github.com/BKmetoff/endurosat-assignment/) authenticate in AWS via an [AWS OIDC token](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) that is created as part of the ECR module.
- the Terraform state (backend) is saved in a dedicated [AWS S3 bucket](https://developer.hashicorp.com/terraform/language/settings/backends/s3);
