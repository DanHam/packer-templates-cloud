data "aws_ami" "debian9_ami" {
  most_recent = true
  name_regex  = "Debian 9 Base HVM \\d{4}-\\d{2}-\\d{2}"
  owners      = ["self"]
}

output "debian9_ami" {
  description = "Discovered AMI:"
  value       = "${data.aws_ami.debian9_ami.name}: ${data.aws_ami.debian9_ami.id}"
}

resource "aws_instance" "debian9_test" {
  ami                    = data.aws_ami.debian9_ami.id
  instance_type          = var.aws_instance_type
  user_data              = filebase64(var.aws_instance_user_data_file)
  vpc_security_group_ids = [aws_security_group.linux.id]

  volume_tags = merge(
    local.common_tags,
    {
      "BuiltBy" = "Packer"
      "Name"    = "Terraform Test: ${data.aws_ami.debian9_ami.name}"
    }
  )

  tags = merge(
    local.common_tags,
    {
      "BuiltBy" = "Packer"
      "Name"    = "Terraform Test: ${data.aws_ami.debian9_ami.name}"
    }
  )
}

data "aws_ami" "debian10_ami" {
  most_recent = true
  name_regex  = "Debian 10 Base HVM \\d{4}-\\d{2}-\\d{2}"
  owners      = ["self"]
}

output "debian10_ami" {
  description = "Discovered AMI:"
  value       = "${data.aws_ami.debian10_ami.name}: ${data.aws_ami.debian10_ami.id}"
}

resource "aws_instance" "debian10_test" {
  ami                    = data.aws_ami.debian10_ami.id
  instance_type          = var.aws_instance_type
  user_data              = filebase64(var.aws_instance_user_data_file)
  vpc_security_group_ids = [aws_security_group.linux.id]

  volume_tags = merge(
    local.common_tags,
    {
      "BuiltBy" = "Packer"
      "Name"    = "Terraform Test: ${data.aws_ami.debian10_ami.name}"
    }
  )

  tags = merge(
    local.common_tags,
    {
      "BuiltBy" = "Packer"
      "Name"    = "Terraform Test: ${data.aws_ami.debian10_ami.name}"
    }
  )
}
