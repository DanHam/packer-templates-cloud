data "aws_ami" "centos7_ami" {
  most_recent = true
  name_regex  = "CentOS 7 Base HVM \\d{4}-\\d{2}-\\d{2}"
  owners      = ["self"]
}

output "centos7_ami" {
  description = "Discovered AMI:"
  value       = "${data.aws_ami.centos7_ami.name}: ${data.aws_ami.centos7_ami.id}"
}

resource "aws_instance" "centos7_test" {
  ami           = data.aws_ami.centos7_ami.id
  instance_type = var.aws_instance_type
  user_data     = filebase64(var.aws_instance_user_data_file)

  volume_tags = local.common_tags

  tags = merge(
    local.common_tags,
    {
      "BuiltBy" = "Packer"
    }
  )
}
