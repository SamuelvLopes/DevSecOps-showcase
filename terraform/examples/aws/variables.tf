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
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "instance_size" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "Public SSH key authorized for the Ubuntu user."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to access SSH. Use your public IP with /32."
  type        = string
}
