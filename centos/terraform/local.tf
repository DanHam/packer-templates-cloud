locals {
  common_tags = {
    "createdBy" = "terraform"
  }
  instance_tags = {
    "Name" = "Terraform Test: ${data.aws_ami.centos7_ami.name}"
  }
}
