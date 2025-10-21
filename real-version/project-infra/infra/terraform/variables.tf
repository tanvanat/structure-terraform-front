# -------------------------
# OpenStack Credentials
# -------------------------
# variable "os_username" {
#   description = "OpenStack username"
#   type        = string
# }

# variable "os_password" {
#   description = "OpenStack password"
#   type        = string
#   sensitive   = true
# }

# variable "os_tenant_name" {
#   description = "OpenStack tenant/project"
#   type        = string
# }

# variable "os_domain_name" {
#   description = "OpenStack domain name"
#   type        = string
# }

# variable "os_auth_url" {
#   description = "OpenStack auth URL"
#   type        = string
# }

# variable "os_region" {
#   description = "OpenStack region"
#   type        = string
# }

# -------------------------
# Network
# -------------------------
variable "vpc_network_name" {
  description = "VPC network name"
  type        = string
  default     = "k0s-vpc-network"
}

variable "vpc_subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "k0s-vpc-subnet"
}

variable "vpc_subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_subnet_gateway_ip" {
  description = "Subnet gateway IP"
  type        = string
  default     = "10.0.0.1"
}

variable "vpc_dns_nameservers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# -------------------------
# Security Group
# -------------------------
variable "security_group_name" {
  description = "Security group name for k0s"
  type        = string
  default     = "k0s-cluster-sg"
}

# -------------------------
# Key Pair
# -------------------------
variable "key_pair_name" {
  description = "Name of an existing OpenStack keypair to inject"
  type        = string
  default     = "Fronttest-WSL"
}

# -------------------------
# SSH
# -------------------------
variable "ssh_user" {
  description = "Default SSH user"
  type        = string
  default     = "ubuntu"
}

variable "private_key_path" {
  description = "Path to the private SSH key file on your local machine"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# -------------------------
# Image / Flavors / Volumes
# -------------------------
variable "os_image_id" {
  description = "Image ID for boot volume"
  type        = string
  default     = "30c876dd-4470-47d8-b13a-df5f18c85ba4"
}

variable "control_plane_flavor" {
  description = "Flavor for control plane"
  type        = string
  default     = "csa.large.v2"
}

variable "control_plane_volume_size" {
  description = "Size (GB) of the control plane volume"
  type        = number
  default     = 20
}

variable "worker_flavor" {
  description = "Flavor for worker nodes"
  type        = string
  default     = "csa.large.v2"
}

variable "worker_volume_size" {
  description = "Size (GB) of worker volumes"
  type        = number
  default     = 20
}

variable "volume_type_ssd" {
  description = "Cinder volume type"
  type        = string
  default     = "Premium_SSD"
}

# -------------------------
# Availability Zones / IP Pools
# -------------------------
variable "availability_zone_non" {
  description = "AZ for NON"
  type        = string
  default     = "NCP-NON"
}

variable "public_ip_pool_name_non" {
  description = "Public IP pool NON"
  type        = string
  default     = "Standard_Public_IP_Pool_NON"
}

variable "availability_zone_bkk" {
  description = "AZ for BKK"
  type        = string
  default     = "NCP-BKK"
}

variable "public_ip_pool_name_bkk" {
  description = "Public IP pool BKK"
  type        = string
  default     = "Standard_Public_IP_Pool_BKK"
}

# -------------------------
# Instance Names
# -------------------------
variable "control_plane_name_non" {
  description = "Control plane NON name"
  type        = string
  default     = "Master-NON"
}

variable "worker_1_non_name" {
  description = "Worker-1 NON name"
  type        = string
  default     = "worker-1-NON"
}

variable "worker_2_non_name" {
  description = "Worker-2 NON name"
  type        = string
  default     = "worker-2-NON"
}

variable "control_plane_name_bkk" {
  description = "Control plane BKK name"
  type        = string
  default     = "Master-BKK"
}

variable "worker_1_bkk_name" {
  description = "Worker-1 BKK name"
  type        = string
  default     = "Worker-1-BKK"
}

variable "worker_2_bkk_name" {
  description = "Worker-2 BKK name"
  type        = string
  default     = "Worker-2-BKK"
}

variable "argocd_non_name" {
  description = "Name for Argo CD single-node in NON"
  type        = string
  default     = "ArgoCD-NON"
}

variable "prod_non_name" {
  description = "Name for Prod single-node in NON (HAProxy)"
  type        = string
  default     = "Prod-NON"
}

# -------------------------
# GitHub Token (Sensitive)
# -------------------------
variable "token_for_github" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}
