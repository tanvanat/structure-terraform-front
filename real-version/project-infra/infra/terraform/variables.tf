########################################
# VARIABLES.TF — OpenStack K0s Cluster
########################################

# -------------------------
# Network
# -------------------------
variable "vpc_network_name" {
  type        = string
  default     = "k0s-vpc-network"
  description = "VPC network name"
}

variable "vpc_subnet_name" {
  type        = string
  default     = "k0s-vpc-subnet"
  description = "Subnet name"
}

variable "vpc_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "Subnet CIDR"
}

variable "vpc_subnet_gateway_ip" {
  type        = string
  default     = "10.0.0.1"
  description = "Subnet gateway IP"
}

variable "vpc_dns_nameservers" {
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
  description = "List of DNS nameservers"
}

# Which external/public network to allocate Floating IPs from
variable "external_network_name" {
  type        = string
  description = "Provider external network name (e.g. 'public' or your cloud's external net)"
  default = "public"
}

variable "public_ip_pool_name_non" {
  description = "ชื่อของ public IP pool สำหรับ Prod-NON"
  type        = string
  default = "Standard_Public_IP_Pool_NON"
}

# -------------------------
# Security Group
# -------------------------
variable "security_group_name" {
  type        = string
  default     = "k0s-cluster-sg"
  description = "Security group name for K0s"
}

# -------------------------
# Key Pair (existing)
# -------------------------
variable "key_pair_name" {
  type        = string
  default     = "Fronttest-WSL"
  description = "Existing OpenStack keypair name"
}

# -------------------------
# SSH
# -------------------------
variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "Default SSH user for instances"
}

variable "private_key_path" {
  type        = string
  default     = "~/.ssh/Fronttest.pem"
  description = "Path to the private SSH key on local machine"
}

# -------------------------
# Image / Flavors / Volumes
# -------------------------
variable "os_image_id" {
  type        = string
  default     = "30c876dd-4470-47d8-b13a-df5f18c85ba4"
  description = "Image ID used to boot instances"
}

variable "control_plane_flavor" {
  type        = string
  default     = "csa.large.v2"
  description = "Flavor for control plane instances"
}

variable "control_plane_volume_size" {
  type        = number
  default     = 100
  description = "Volume size (GB) for control plane nodes"
}

variable "worker_flavor" {
  type        = string
  default     = "csa.large.v2"
  description = "Flavor for worker nodes"
}

variable "worker_volume_size" {
  type        = number
  default     = 100
  description = "Volume size (GB) for worker nodes"
}

variable "volume_type_ssd" {
  type        = string
  default     = "Premium_SSD"
  description = "Cinder volume type for SSD"
}

# -------------------------
# Availability Zones / IP Pools
# -------------------------
variable "availability_zone_non" {
  type        = string
  default     = "NCP-NON"
  description = "Availability Zone for NON (backup zone)"
}

variable "availability_zone_bkk" {
  type        = string
  default     = "NCP-BKK"
  description = "Availability Zone for BKK (main zone)"
}

# -------------------------
# Instance Names
# -------------------------
variable "control_plane_name_non" {
  type        = string
  default     = "Master-NON"
  description = "Control plane instance name in NON zone"
}

variable "worker_1_non_name" {
  type        = string
  default     = "worker-1-NON"
  description = "Worker 1 instance name in NON zone"
}

variable "worker_2_non_name" {
  type        = string
  default     = "worker-2-NON"
  description = "Worker 2 instance name in NON zone"
}

variable "control_plane_name_bkk" {
  type        = string
  default     = "Master-BKK"
  description = "Control plane instance name in BKK zone"
}

variable "worker_1_bkk_name" {
  type        = string
  default     = "Worker-1-BKK"
  description = "Worker 1 instance name in BKK zone"
}

variable "worker_2_bkk_name" {
  type        = string
  default     = "Worker-2-BKK"
  description = "Worker 2 instance name in BKK zone"
}

variable "argocd_non_name" {
  type        = string
  default     = "ArgoCD-NON"
  description = "Single-node instance for Argo CD (NON zone)"
}

variable "prod_non_name" {
  type        = string
  default     = "Prod-NON"
  description = "Single-node instance for HAProxy/Production (NON zone)"
}

variable "my_ip_cidr" {
  description = "Your current public IP in CIDR (e.g., 49.x.x.x/32)"
  type        = string
  default     = "103.10.231.150/32"
}


# -------------------------
# GitHub Token (Sensitive)
# -------------------------
variable "token_for_github" {
  type        = string
  sensitive   = true
  default     = "REDACT_ME"
  description = "GitHub Personal Access Token (for GitOps)"
}
