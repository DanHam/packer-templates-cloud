provider "aws" {
  region  = var.aws_region
  version = "~> 3.2.0"
  profile = "terraform"
}