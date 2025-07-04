terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "hashicorp/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  # Terraform จะอ่านค่าเหล่านี้จาก Environment Variables ที่ถูกตั้งค่าโดยไฟล์ .sh
  region      = "NCP-TH"
}

resource "openstack_compute_instance_v2" "basic_instance" {
  name            = var.instance_name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  security_groups = var.security_groups

  network {
    name = var.network_name
  }
}