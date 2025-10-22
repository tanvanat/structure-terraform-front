
#ให้ใช้key-pair ที่มีอยู่แล้วเเทนที่จะสร้างใหม่
data "openstack_compute_keypair_v2" "keypair" {
  name = var.key_pair_name
}


resource "openstack_networking_network_v2" "network" {
  name     = var.vpc_network_name
  external = false
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = var.vpc_subnet_name
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.vpc_subnet_cidr
  gateway_ip      = var.vpc_subnet_gateway_ip
  dns_nameservers = var.vpc_dns_nameservers
}

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = var.security_group_name
  description = "Security group for k0s cluster"
}

# Rule สำหรับอนุญาตการเข้าถึง SSH จากทุก IP
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# Rule สำหรับ Kubernetes API eg.ให้worker nodeเข้าถึงkubernetes API server ที่รันอยู่ในcontrol plane 6443
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

#icmp
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

#-----------------------
# Master-NON
#-----------------------
resource "openstack_networking_port_v2" "port_control" {
  name       = "port_master_NON"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "floatip_control" {
  pool = var.public_ip_pool_name_non
}

resource "openstack_networking_floatingip_associate_v2" "fip_control" {
  floating_ip = openstack_networking_floatingip_v2.floatip_control.address
  port_id     = openstack_networking_port_v2.port_control.id
}

resource "openstack_compute_instance_v2" "control_plane" {
  name = var.control_plane_name_non
  # image_id          = var.os_image_id
  flavor_name = var.control_plane_flavor
  key_pair    = data.openstack_compute_keypair_v2.keypair.name

  # security_groups   = ["default", "SSH", "ALL"]
  availability_zone = var.availability_zone_non

  network {
    port = openstack_networking_port_v2.port_control.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.control_plane_volume_size
    delete_on_termination = true
  }
}

#-----------------------
# Worker-1-NON
#-----------------------
resource "openstack_networking_port_v2" "port_worker_1_NON" {
  name       = "port_worker_1_NON"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "floatip_worker_1_NON" {
  pool = var.public_ip_pool_name_non
}

resource "openstack_networking_floatingip_associate_v2" "fip_worker_1_NON" {
  floating_ip = openstack_networking_floatingip_v2.floatip_worker_1_NON.address
  port_id     = openstack_networking_port_v2.port_worker_1_NON.id
}

resource "openstack_compute_instance_v2" "worker_1_NON" {
  name = var.worker_1_non_name
  # image_id          = var.os_image_id
  flavor_name = var.worker_flavor
  key_pair    = data.openstack_compute_keypair_v2.keypair.name

  # security_groups   = ["default", "SSH", "ALL"]
  availability_zone = var.availability_zone_non

  network {
    port = openstack_networking_port_v2.port_worker_1_NON.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }
}

#-----------------------
# Worker-2-NON
#-----------------------
resource "openstack_networking_port_v2" "port_worker_2_NON" {
  name       = "port_worker_2_NON"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "floatip_worker_2_NON" {
  pool = var.public_ip_pool_name_non
}

resource "openstack_networking_floatingip_associate_v2" "fip_worker_2_NON" {
  floating_ip = openstack_networking_floatingip_v2.floatip_worker_2_NON.address
  port_id     = openstack_networking_port_v2.port_worker_2_NON.id
}

resource "openstack_compute_instance_v2" "worker_2_NON" {
  name              = var.worker_2_non_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non

  network {
    port = openstack_networking_port_v2.port_worker_2_NON.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    volume_type           = var.volume_type_ssd
    delete_on_termination = true
  }
}

# -----------------------
# 2.4) Argo CD - NON (Single node)
# -----------------------
resource "openstack_networking_port_v2" "port_argocd_non" {
  name       = "port_argocd_NON"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "fip_argocd_non" {
  pool = var.public_ip_pool_name_non
}

resource "openstack_networking_floatingip_associate_v2" "assoc_argocd_non" {
  floating_ip = openstack_networking_floatingip_v2.fip_argocd_non.address
  port_id     = openstack_networking_port_v2.port_argocd_non.id
}

resource "openstack_compute_instance_v2" "argocd_non" {
  name              = var.argocd_non_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non

  network {
    port = openstack_networking_port_v2.port_argocd_non.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }

  # ถ้ามี cloud-init user_data สำหรับติดตั้ง k0s + Argo CD ค่อยใส่ภายหลัง
  # user_data = file("${path.module}/cloudinit/argocd.yaml")
}

# -----------------------
# 2.5) Prod - NON (Single node with HAProxy)
# -----------------------
resource "openstack_networking_port_v2" "port_prod_non" {
  name       = "port_prod_NON"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "fip_prod_non" {
  pool = var.public_ip_pool_name_non
}

resource "openstack_networking_floatingip_associate_v2" "assoc_prod_non" {
  floating_ip = openstack_networking_floatingip_v2.fip_prod_non.address
  port_id     = openstack_networking_port_v2.port_prod_non.id
}

resource "openstack_compute_instance_v2" "prod_non" {
  name              = var.prod_non_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non

  network {
    port = openstack_networking_port_v2.port_prod_non.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }

  # ภายหลังสามารถใส่ cloud-init ติดตั้ง HAProxy + certbot/CF tunnel ได้
  # user_data = file("${path.module}/cloudinit/prod-haproxy.yaml")
}

# -----------------------
# Master-BKK (Control Plane)
# -----------------------
resource "openstack_networking_port_v2" "port_master_bkk" {
  name       = "port_master_BKK"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "fip_master_bkk" {
  pool = var.public_ip_pool_name_bkk
}

resource "openstack_networking_floatingip_associate_v2" "assoc_master_bkk" {
  floating_ip = openstack_networking_floatingip_v2.fip_master_bkk.address
  port_id     = openstack_networking_port_v2.port_master_bkk.id
}

resource "openstack_compute_instance_v2" "control_plane_bkk" {
  name              = var.control_plane_name_bkk
  flavor_name       = var.control_plane_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_bkk

  network {
    port = openstack_networking_port_v2.port_master_bkk.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.control_plane_volume_size
    delete_on_termination = true
  }
}

# -----------------------
# Worker-1-BKK
# -----------------------
resource "openstack_networking_port_v2" "port_worker_1_bkk" {
  name       = "port_worker_1_BKK"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "fip_worker_1_bkk" {
  pool = var.public_ip_pool_name_bkk
}

resource "openstack_networking_floatingip_associate_v2" "assoc_worker_1_bkk" {
  floating_ip = openstack_networking_floatingip_v2.fip_worker_1_bkk.address
  port_id     = openstack_networking_port_v2.port_worker_1_bkk.id
}

resource "openstack_compute_instance_v2" "worker_1_bkk" {
  name              = var.worker_1_bkk_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_bkk

  network {
    port = openstack_networking_port_v2.port_worker_1_bkk.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }
}

# -----------------------
# Worker-2-BKK
# -----------------------
resource "openstack_networking_port_v2" "port_worker_2_bkk" {
  name       = "port_worker_2_BKK"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "fip_worker_2_bkk" {
  pool = var.public_ip_pool_name_bkk
}

resource "openstack_networking_floatingip_associate_v2" "assoc_worker_2_bkk" {
  floating_ip = openstack_networking_floatingip_v2.fip_worker_2_bkk.address
  port_id     = openstack_networking_port_v2.port_worker_2_bkk.id
}

resource "openstack_compute_instance_v2" "worker_2_bkk" {
  name              = var.worker_2_bkk_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_bkk

  network {
    port = openstack_networking_port_v2.port_worker_2_bkk.id
  }

  block_device {
    uuid             = var.os_image_id
    source_type      = "image"
    boot_index       = 0
    destination_type = "volume"
    volume_size      = var.worker_volume_size
    # ถ้าต้องการระบุชนิดดิสก์เหมือนตัว NON:
    # volume_type           = var.volume_type_ssd
    delete_on_termination = true
  }
}


# Outputs
output "master_NON_public_ip" {
  value = openstack_networking_floatingip_v2.floatip_control.address
}

output "worker_1_NON_public_ip" {
  value = openstack_networking_floatingip_v2.floatip_worker_1_NON.address
}

output "worker_2_NON_public_ip" {
  value = openstack_networking_floatingip_v2.floatip_worker_2_NON.address
}

output "argocd_NON_public_ip" {
  value = openstack_networking_floatingip_v2.fip_argocd_non.address
}

output "prod_NON_public_ip" {
  value = openstack_networking_floatingip_v2.fip_prod_non.address
}


output "master_BKK_public_ip" {
  value = openstack_networking_floatingip_v2.fip_master_bkk.address
}
output "worker_1_BKK_public_ip" {
  value = openstack_networking_floatingip_v2.fip_worker_1_bkk.address
}
output "worker_2_BKK_public_ip" {
  value = openstack_networking_floatingip_v2.fip_worker_2_bkk.address
}
