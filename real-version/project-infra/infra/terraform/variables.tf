# variables.tf

# OpenStack Credentials
variable "os_username" {
  description = "OpenStack username"
  type        = string
  default     = "tanvanat@nipa.cloud" # เปลี่ยนเป็น username ของคุณ
}

variable "os_password" {
  description = "OpenStack password"
  type        = string
  sensitive   = true
}

variable "os_tenant_name" {
  description = "OpenStack tenant/project name"
  type        = string
  default     = "Terraform_test" # เปลี่ยนเป็น tenant/project name ของคุณ
}

variable "os_domain_name" {
  description = "OpenStack domain name"
  type        = string
  default     = "nipacloud" # เปลี่ยนเป็น domain name ของคุณ
}

variable "os_auth_url" {
  description = "OpenStack authentication URL"
  type        = string
  default     = "https://stg.thaiopenstack.com:5000" # เปลี่ยนเป็น Auth URL ของคุณ
}

variable "os_region" {
  description = "OpenStack region"
  type        = string
  default     = "NCP-TH" # เปลี่ยนเป็น Region ของคุณ
}

# Network
variable "vpc_network_name" {
  description = "Name for the new VPC network"
  type        = string
  default     = "k0s-vpc-network"
}

variable "vpc_subnet_name" {
  description = "Name for the subnet inside the new VPC"
  type        = string
  default     = "k0s-vpc-subnet"
}

variable "vpc_subnet_cidr" {
  description = "CIDR block for the new VPC subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_subnet_gateway_ip" {
  description = "Gateway IP for the new VPC subnet"
  type        = string
  default     = "10.0.0.1"
}

variable "vpc_dns_nameservers" {
  description = "List of DNS nameservers for the VPC subnet"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# Security Group
variable "security_group_name" {
  description = "Name for the k0s cluster security group"
  type        = string
  default     = "k0s-cluster-sg" # ชื่อ Security Group ใหม่

}

# Key Pair
variable "key_pair_name" {
  description = "Name of the SSH Key Pair to upload to OpenStack"
  type        = string
  default     = "Fronttest-WSL"
}

variable "public_key_path" {
  description = "Path to the public SSH key file on your local machine (e.g., ~/.ssh/id_rsa.pub)"
  type        = string
  # IMPORTANT: Adjust this path to your actual public key file location on the machine running Terraform
  default     = "~/.ssh/id_rsa.pub" # <--- **เปลี่ยน Path นี้ให้ถูกต้องบน Linux VM (instance-1)**
}

variable "ssh_user" {
  description = "Default SSH user for instances (e.g., ubuntu, centos)"
  type        = string
  default     = "ubuntu" # เปลี่ยนเป็น User ที่ใช้ SSH เข้า VM
}

# Instance Configuration
variable "os_image_id" {
  description = "ID of the image to use for instance boot volumes (e.g., '30c876dd-4470-47d8-b13a-df5f18c85ba4')"
  type        = string
  default     = "30c876dd-4470-47d8-b13a-df5f18c85ba4" # เปลี่ยนเป็น Image ID ที่ถูกต้องของคุณ
}

variable "availability_zone" {
  description = "Availability Zone for all instances and volumes"
  type        = string
  default     = "NCP-NON" # <--- **ต้องตรงกับ AZ ที่คุณต้องการสร้าง Instance และ Volume จริงๆ**
}

variable "public_ip_pool_name" {
  description = "Name of the public IP pool for Floating IPs"
  type        = string
  default     = "Standard_Public_IP_Pool_NON" # เปลี่ยนเป็นชื่อ Public IP Pool ของคุณ
}

variable "volume_type_ssd" {
  description = "Volume type for SSDs (e.g., Premium_SSD)"
  type        = string
  default     = "Premium_SSD"
}

# Control Plane
variable "control_plane_name" {
  description = "Name for the Control Plane instance"
  type        = string
  default     = "Master-NON"
}

variable "control_plane_flavor" {
  description = "Flavor name for the Control Plane instance"
  type        = string
  default     = "csa.large.v2" # เปลี่ยนเป็น Flavor ที่ต้องการ
}

variable "control_plane_volume_size" {
  description = "Size of the boot volume for the Control Plane (in GB)"
  type        = number
  default     = 20
}

# Worker-1-NON
variable "worker_1_NON_name" {
  description = "Name for worker-1 instance"
  type        = string
  default     = "worker-1-NON"
}

variable "worker_1_NON_node_count" {
  description = "Number of Kubernetes worker nodes to deploy"
  type        = number
  default     = 1 # จำนวน Worker Nodes ที่ต้องการ
}

variable "worker_1_NON_flavor" {
  description = "Flavor name for the Worker nodes"
  type        = string
  default     = "csa.large.v2" # เปลี่ยนเป็น Flavor ที่ต้องการ
}

variable "worker_1_NON_volume_size" {
  description = "Size of the boot volume for Worker nodes (in GB)"
  type        = number
  default     = 20
}



# For remote-exec provisioners (if uncommented later)
variable "private_key_path" {
  description = "Path to the private SSH key file on your local machine (for provisioners)"
  type        = string
  default     = "~/.ssh/id_rsa" # <--- **เปลี่ยน Path นี้ให้ถูกต้องบน Linux VM (instance-1)**
}

variable "token_for_github" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

