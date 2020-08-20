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

variable "aws_instance_user_data_file" {
  description = "Path to the Cloud Init user data file with which to instantiate the instance"
  default     = "userdata.yaml"
  type        = string
}
