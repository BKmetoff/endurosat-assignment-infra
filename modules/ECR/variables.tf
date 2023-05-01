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

variable "environments" {
  description = "The names of the repository environments, i.e. 'production','staging', etc."
  type        = list(string)
}
