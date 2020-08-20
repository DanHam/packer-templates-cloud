locals {
  common_tags = {
    "CreatedBy" = "Terraform"
    "Name"      = "Terraform Test: ${data.aws_ami.centos7_ami.name}"
  }
}
