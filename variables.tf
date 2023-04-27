variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name_base" {
  default = "endurosat-assignment"
  type    = string
}
