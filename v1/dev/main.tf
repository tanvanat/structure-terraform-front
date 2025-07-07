# control_plane_public_ip = "10.112.2.30"
# worker_public_ip = "10.112.2.37"

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

resource "openstack_networking_port_v2" "port_control" {
  name               = "port_front"
  network_id         = openstack_networking_network_v2.network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "floatip_control" {
  pool = var.public_ip_pool_name
}

resource "openstack_networking_floatingip_associate_v2" "fip_control" {
  floating_ip = openstack_networking_floatingip_v2.floatip_control.address
  port_id     = openstack_networking_port_v2.port_control.id
}

resource "openstack_compute_instance_v2" "control_plane" {
  name              = var.control_plane_name
  image_id          = var.os_image_id
  flavor_name       = var.control_plane_flavor
  key_pair = data.openstack_compute_keypair_v2.keypair.name

  # security_groups   = ["default", "SSH", "ALL"]
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_control.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.control_plane_volume_size
    delete_on_termination = false
  }
}

resource "openstack_networking_port_v2" "port_worker" {
  name               = "port_worker"
  network_id         = openstack_networking_network_v2.network.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

resource "openstack_networking_floatingip_v2" "floatip_worker" {
  pool = var.public_ip_pool_name
}

resource "openstack_networking_floatingip_associate_v2" "fip_worker" {
  floating_ip = openstack_networking_floatingip_v2.floatip_worker.address
  port_id     = openstack_networking_port_v2.port_worker.id
}

resource "openstack_compute_instance_v2" "worker" {
  name              = "worker"
  image_id          = var.os_image_id
  flavor_name       = var.worker_flavor
  key_pair = data.openstack_compute_keypair_v2.keypair.name

  # security_groups   = ["default", "SSH", "ALL"]
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.port_worker.id
  }

  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = false
  }
}

output "control_plane_public_ip" {
  value = openstack_networking_floatingip_v2.floatip_control.address
}

output "worker_public_ip" {
  value = openstack_networking_floatingip_v2.floatip_worker.address
}
