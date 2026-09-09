variable "project_name" {
  description = "Prefix used for resource names and tags."
  type        = string
  default     = "projeto-korp"
}

variable "environment" {
  description = "Environment label."
  type        = string
  default     = "demo"
}

variable "region" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "instance_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "ssh_public_key" {
  description = "Public SSH key authorized for the azureuser account."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to access SSH. Use your public IP with /32."
  type        = string
}
