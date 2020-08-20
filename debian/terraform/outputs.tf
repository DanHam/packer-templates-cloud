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
