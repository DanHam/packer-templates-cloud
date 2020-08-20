output "aws_instance_ip" {
  description = "Instance IP:"
  value       = aws_instance.centos7_test.public_ip
}

output "aws_instance_dns" {
  description = "Instance DNS:"
  value       = aws_instance.centos7_test.public_dns
}
