output "debian9_ami" {
  description = "Discovered Debian 9 AMI:"
  value       = "${data.aws_ami.debian9_ami.name}: ${data.aws_ami.debian9_ami.id}"
}

output "debian10_ami" {
  description = "Discovered Debian 10 AMI:"
  value       = "${data.aws_ami.debian10_ami.name}: ${data.aws_ami.debian10_ami.id}"
}

output "debian11_ami" {
  description = "Discovered Debian 11 AMI:"
  value       = "${data.aws_ami.debian11_ami.name}: ${data.aws_ami.debian11_ami.id}"
}

output "aws_instance_debian9_ip" {
  description = "Debian 9 Instance IP:"
  value       = aws_instance.debian9_test.public_ip
}

output "aws_instance_debian9_dns" {
  description = "Debian 9 Instance DNS:"
  value       = aws_instance.debian9_test.public_dns
}

output "aws_instance_debian10_ip" {
  description = "Debian 10 Instance IP:"
  value       = aws_instance.debian10_test.public_ip
}

output "aws_instance_debian10_dns" {
  description = "Debian 10 Instance DNS:"
  value       = aws_instance.debian10_test.public_dns
}

output "aws_instance_debian11_ip" {
  description = "Debian 11 Instance IP:"
  value       = aws_instance.debian11_test.public_ip
}

output "aws_instance_debian11_dns" {
  description = "Debian 11 Instance DNS:"
  value       = aws_instance.debian11_test.public_dns
}
