locals {
  common_tags = {
    "CreatedBy" = "Terraform"
  }
  instance_tags = {
    "Name" = "Terraform Test: ${data.aws_ami.centos7_ami.name}"
  }
}
