
variable "instance_name" {
  default     = "terraform-instance"
}

variable "image_name" {
  default     = "ubuntu-20-v220723" 
}

variable "flavor_name" {
  default     = "csa.large.v2"
}

variable "security_groups" {
  default     = ["default"]
}

variable "network_name" {
  default     = "default"
}