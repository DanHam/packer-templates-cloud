variable "aws_region" {
  description = "The AWS region in which to create the infrastructure resources"
  default     = "eu-west-2"
  type        = string
}

variable "aws_instance_type" {
  description = "The AWS instance type to use"
  default     = "t2.micro"
  type        = string
}
