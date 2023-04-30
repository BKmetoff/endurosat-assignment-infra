variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
}

variable "name" {
  description = "A name to identify VPC-related resources by"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "How many subnets should be created"
  type        = number
}

