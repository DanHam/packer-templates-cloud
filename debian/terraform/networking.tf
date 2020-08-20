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
