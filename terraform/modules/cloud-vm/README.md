# Cloud VM contract

This directory documents the common interface used by the provider-specific
Terraform examples. It is intentionally a contract instead of a universal module:
AWS and Azure expose different primitives, so each example keeps its native
resources while returning the same outputs for Ansible.

## Inputs

| Name | Description |
| --- | --- |
| `project_name` | Prefix used for resource names and tags. |
| `environment` | Environment label, for example `demo`. |
| `region` | Cloud provider region. |
| `ssh_public_key` | Public SSH key authorized on the VM. |
| `allowed_ssh_cidr` | CIDR allowed to reach TCP/22. |
| `instance_size` | Provider-specific VM size. |

## Outputs

| Name | Description |
| --- | --- |
| `public_ip` | Public IPv4 address assigned to the VM. |
| `ssh_user` | Default SSH user for the Ubuntu image. |
| `ansible_inventory` | Minimal inventory content consumed by Ansible. |

Terraform provisions infrastructure only. The application deployment remains in
Ansible so the infrastructure automation and configuration automation stay easy
to inspect independently.
