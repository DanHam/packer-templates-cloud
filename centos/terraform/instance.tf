data "aws_ami" "centos7_ami" {
  most_recent = true
  name_regex  = "CentOS 7 Base HVM \\d{4}-\\d{2}-\\d{2}"
  owners      = ["self"]
}

output "centos7_ami" {
  description = "Discovered AMI:"
  value       = "${data.aws_ami.centos7_ami.name}: ${data.aws_ami.centos7_ami.id}"
}
