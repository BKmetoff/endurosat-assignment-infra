variable "app_count" {
  type    = number
  default = 1
}

variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-1"
}
