variable "name" {
  description = "The name of this repository"
  type        = string
}

variable "github_actions" {
  type = object({
    oidc_arn     = string
    organization = string
    repository   = string
  })
}
