# กำหนดเวอร์ชันของ Terraform และ Provider ที่ต้องการ
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0.0"
    }
  }
}

# กำหนดค่า Provider สำหรับ OpenStack
# ควรใช้ Environment Variables หรือ terraform.tfvars เพื่อความปลอดภัย
provider "openstack" {
  auth_url    = var.os_auth_url
  region      = var.os_region
  user_name   = var.os_username
  password    = var.os_password # ใช้ตัวแปร
  tenant_name = var.os_tenant_name
  domain_name = var.os_domain_name
}
