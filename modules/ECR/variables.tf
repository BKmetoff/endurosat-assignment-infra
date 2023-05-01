variable "name" {
  description = "The name of this repository (should match the name of the GH repo)"
  type        = string
}

variable "github_actions" {
  type = object({
    organization = string
    repository   = string
  })
}

variable "environment" {
  description = "The name of the repository environment, i.e. 'production','staging', etc."
  type        = string
}