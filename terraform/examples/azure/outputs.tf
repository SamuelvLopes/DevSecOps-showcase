output "public_ip" {
  description = "Public IPv4 address assigned to the VM."
  value       = azurerm_public_ip.main.ip_address
}

output "ssh_user" {
  description = "Default SSH user for the Azure VM."
  value       = "azureuser"
}

output "ansible_inventory" {
  description = "Minimal Ansible inventory for the provisioned VM."
  value       = <<-EOT
  [korp]
  ${azurerm_public_ip.main.ip_address} ansible_user=azureuser
  EOT
}
