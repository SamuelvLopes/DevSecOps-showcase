output "public_ip" {
  description = "Public IPv4 address assigned to the VM."
  value       = aws_instance.app.public_ip
}

output "ssh_user" {
  description = "Default SSH user for the Ubuntu AMI."
  value       = "ubuntu"
}

output "ansible_inventory" {
  description = "Minimal Ansible inventory for the provisioned VM."
  value       = <<-EOT
  [korp]
  ${aws_instance.app.public_ip} ansible_user=ubuntu
  EOT
}
