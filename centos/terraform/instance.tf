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
  ami                    = data.aws_ami.centos7_ami.id
  instance_type          = var.aws_instance_type
  user_data              = filebase64(var.aws_instance_user_data_file)
  vpc_security_group_ids = [aws_security_group.linux.id]

  volume_tags = merge(
    local.common_tags,
    local.instance_tags
  )

  tags = merge(
    local.common_tags,
    local.instance_tags,
    {
      "BuiltBy" = "Packer"
    }
  )
}
