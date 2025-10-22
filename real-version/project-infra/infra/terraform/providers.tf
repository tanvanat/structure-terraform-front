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
  
}