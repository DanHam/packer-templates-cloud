locals {
  common_tags = {
    "createdBy" = "terraform"
  }
}

# -----------------------------------------------------------------------------
#
# Networking
#
# -----------------------------------------------------------------------------

resource "aws_security_group" "linux" {
  name        = "Terraform Default Linux Debian"
  description = "Rules for traffic to and from Debian GNU/Linux based instances"

  # Allow ssh
  ingress {
    description = "Allow inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.local_ip_cidr]
  }

  # Allow ICMP Echo requests
  ingress {
    description = "Allow ICMP Echo requests"
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.local_ip_cidr]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "Terraform Default Linux Debian"
    }
  )
}

# -----------------------------------------------------------------------------
#
# Instances: Debian 9
#
# -----------------------------------------------------------------------------

data "aws_ami" "debian9_ami" {
  most_recent = true
  name_regex  = "Debian 9 Base HVM \\d{4}-\\d{2}-\\d{2}"
  owners      = ["self"]
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

# -----------------------------------------------------------------------------
#
# Instances: Debian 10
#
# -----------------------------------------------------------------------------

data "aws_ami" "debian10_ami" {
  most_recent = true
  name_regex  = "Debian 10 Base HVM \\d{4}-\\d{2}-\\d{2}"
  owners      = ["self"]
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

# -----------------------------------------------------------------------------
#
# Instances: Debian 11
#
# -----------------------------------------------------------------------------

data "aws_ami" "debian11_ami" {
  most_recent = true
  name_regex  = "Debian 11 Base HVM \\d{4}-\\d{2}-\\d{2}"
  owners      = ["self"]
}

resource "aws_instance" "debian11_test" {
  ami                    = data.aws_ami.debian11_ami.id
  instance_type          = var.aws_instance_type
  user_data              = filebase64(var.aws_instance_user_data_file)
  vpc_security_group_ids = [aws_security_group.linux.id]

  volume_tags = merge(
    local.common_tags,
    {
      "BuiltBy" = "Packer"
      "Name"    = "Terraform Test: ${data.aws_ami.debian11_ami.name}"
    }
  )

  tags = merge(
    local.common_tags,
    {
      "BuiltBy" = "Packer"
      "Name"    = "Terraform Test: ${data.aws_ami.debian11_ami.name}"
    }
  )
}
