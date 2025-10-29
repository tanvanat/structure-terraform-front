########################################
# Locals & Data
########################################
locals {
  ssh_user         = var.ssh_user
  private_key_path = var.private_key_path
  cluster_cidr     = var.vpc_subnet_cidr
}

# Existing keypair
data "openstack_compute_keypair_v2" "keypair" {
  name = var.key_pair_name
}

# Reuse the EXISTING router by name and attach our subnet to it
data "openstack_networking_router_v2" "router_non" {
  name = "k0s-router-non"
}

########################################
# Private Network (tenant VPC)
########################################
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

# Attach the existing router to THIS subnet (critical for FIP/NAT)
resource "openstack_networking_router_interface_v2" "router_non_if" {
  router_id = data.openstack_networking_router_v2.router_non.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

########################################
# Security Group (private-first)
########################################
resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = var.security_group_name
  description = "Security group for k0s cluster (private-first)"
}

# ---- Core reachability rules ----

# Allow ALL traffic between members of the SAME SG
# (bastion/prod-non and all cluster nodes share this SG)
resource "openstack_networking_secgroup_rule_v2" "intra_sg_all_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
  remote_group_id   = openstack_networking_secgroup_v2.secgroup_1.id
  # protocol intentionally omitted = allow any (TCP/UDP/ICMP)
}

# Egress allow all (so bastion can open outbound SSH to 10.0.0.0/24, pull packages, etc.)
resource "openstack_networking_secgroup_rule_v2" "egress_all_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# ---- (Optional) keep the explicit, self-documenting k8s ports ----
# SSH inside the private CIDR (bastion -> nodes)
resource "openstack_networking_secgroup_rule_v2" "ssh_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = local.cluster_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# Kubernetes API
resource "openstack_networking_secgroup_rule_v2" "k8s_api_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = local.cluster_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# Kubelet
resource "openstack_networking_secgroup_rule_v2" "kubelet_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = local.cluster_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# etcd
resource "openstack_networking_secgroup_rule_v2" "etcd_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  remote_ip_prefix  = local.cluster_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# controller-manager / scheduler
resource "openstack_networking_secgroup_rule_v2" "cm_sched_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10257
  port_range_max    = 10259
  remote_ip_prefix  = local.cluster_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# NodePort (optional)
resource "openstack_networking_secgroup_rule_v2" "nodeport_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = local.cluster_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# ICMP inside
resource "openstack_networking_secgroup_rule_v2" "icmp_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = local.cluster_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# Public HTTP/HTTPS to LB (Prod-NON)
resource "openstack_networking_secgroup_rule_v2" "lb_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}
resource "openstack_networking_secgroup_rule_v2" "lb_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

# SSH to Prod-NON from your current public IP (for initial bastion access)
resource "openstack_networking_secgroup_rule_v2" "ssh_from_my_ip" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.my_ip_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

########################################
# Ports
########################################
# NON
resource "openstack_networking_port_v2" "port_master_non" {
  name       = "port_master_NON"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}
resource "openstack_networking_port_v2" "port_worker_1_non" {
  name       = "port_worker_1_NON"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}
resource "openstack_networking_port_v2" "port_worker_2_non" {
  name       = "port_worker_2_NON"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}
resource "openstack_networking_port_v2" "port_argocd_non" {
  name       = "port_argocd_NON"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}
resource "openstack_networking_port_v2" "port_prod_non" {
  name       = "port_prod_NON"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

# BKK (same subnet for now)
resource "openstack_networking_port_v2" "port_master_bkk" {
  name       = "port_master_BKK"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}
resource "openstack_networking_port_v2" "port_worker_1_bkk" {
  name       = "port_worker_1_BKK"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}
resource "openstack_networking_port_v2" "port_worker_2_bkk" {
  name       = "port_worker_2_BKK"
  network_id = openstack_networking_network_v2.network.id
  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [openstack_networking_secgroup_v2.secgroup_1.id]
}

########################################
# Floating IP: ONLY Prod-NON (LB/Bastion)
########################################
resource "openstack_networking_floatingip_v2" "fip_prod_non" {
  pool = var.public_ip_pool_name_non
}

resource "openstack_networking_floatingip_associate_v2" "assoc_prod_non" {
  floating_ip = openstack_networking_floatingip_v2.fip_prod_non.address
  port_id     = openstack_networking_port_v2.port_prod_non.id
}

########################################
# Instances
########################################
# NON
resource "openstack_compute_instance_v2" "control_plane_non" {
  name              = var.control_plane_name_non
  flavor_name       = var.control_plane_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non
  network { port = openstack_networking_port_v2.port_master_non.id }
  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.control_plane_volume_size
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "worker_1_non" {
  name              = var.worker_1_non_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non
  network { port = openstack_networking_port_v2.port_worker_1_non.id }
  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "worker_2_non" {
  name              = var.worker_2_non_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non
  network { port = openstack_networking_port_v2.port_worker_2_non.id }
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

resource "openstack_compute_instance_v2" "argocd_non" {
  name              = var.argocd_non_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non
  network { port = openstack_networking_port_v2.port_argocd_non.id }
  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "prod_non" {
  name              = var.prod_non_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_non
  network { port = openstack_networking_port_v2.port_prod_non.id }
  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }
}

# BKK
resource "openstack_compute_instance_v2" "control_plane_bkk" {
  name              = var.control_plane_name_bkk
  flavor_name       = var.control_plane_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_bkk
  network { port = openstack_networking_port_v2.port_master_bkk.id }
  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.control_plane_volume_size
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "worker_1_bkk" {
  name              = var.worker_1_bkk_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_bkk
  network { port = openstack_networking_port_v2.port_worker_1_bkk.id }
  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "worker_2_bkk" {
  name              = var.worker_2_bkk_name
  flavor_name       = var.worker_flavor
  key_pair          = data.openstack_compute_keypair_v2.keypair.name
  availability_zone = var.availability_zone_bkk
  network { port = openstack_networking_port_v2.port_worker_2_bkk.id }
  block_device {
    uuid                  = var.os_image_id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "volume"
    volume_size           = var.worker_volume_size
    delete_on_termination = true
  }
}

########################################
# ssh_config for Ansible (uses Prod-NON FIP)
########################################
resource "local_file" "ssh_config" {
  filename = "${path.module}/ssh_config"
  content = <<-EOT
  Host prod-non
    HostName ${openstack_networking_floatingip_v2.fip_prod_non.address}
    User ubuntu
    IdentityFile ~/.ssh/Fronttest.pem
    IdentitiesOnly yes
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    PreferredAuthentications publickey
    ConnectTimeout 10
    ServerAliveInterval 30
    ServerAliveCountMax 3

  # Any RFC1918 targets go via bastion
  Host 10.* 192.168.* 172.16.* 172.17.* 172.18.* 172.19.* 172.2[0-9].* 172.3[0-1].*
    User ubuntu
    ProxyJump prod-non
    ForwardAgent yes
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    PreferredAuthentications publickey
    ConnectTimeout 10
    ServerAliveInterval 30
    ServerAliveCountMax 3

  # Safety default so Ansible never falls back to passwords and hangs
  Host *
    BatchMode yes
    IdentitiesOnly yes
  EOT
}

########################################
# Run Ansible after files are written
########################################
resource "null_resource" "run_ansible" {
  depends_on = [local_file.ssh_config]

  triggers = {
    ssh_sha  = sha1(local_file.ssh_config.content)
    site_sha = filesha1("${path.module}/../ansible/site.yaml")
    inv_sha  = filesha1("${path.module}/../ansible/inventory.ini")
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "ANSIBLE_SSH_ARGS='-F ${path.module}/ssh_config' SSH_AUTH_SOCK=$SSH_AUTH_SOCK ansible-playbook -i ${path.module}/../ansible/inventory.ini ${path.module}/../ansible/site.yaml"
  }
}

########################################
# Outputs
########################################
output "cluster_private_ips" {
  value = {
    master_bkk  = openstack_networking_port_v2.port_master_bkk.all_fixed_ips[0]
    worker1_bkk = openstack_networking_port_v2.port_worker_1_bkk.all_fixed_ips[0]
    worker2_bkk = openstack_networking_port_v2.port_worker_2_bkk.all_fixed_ips[0]
    master_non  = openstack_networking_port_v2.port_master_non.all_fixed_ips[0]
    worker1_non = openstack_networking_port_v2.port_worker_1_non.all_fixed_ips[0]
    worker2_non = openstack_networking_port_v2.port_worker_2_non.all_fixed_ips[0]
    argocd_non  = openstack_networking_port_v2.port_argocd_non.all_fixed_ips[0]
    prod_non    = openstack_networking_port_v2.port_prod_non.all_fixed_ips[0]
  }
}

# Only one public IP: Prod-NON (bastion + HAProxy)
output "prod_NON_public_ip" {
  value = openstack_networking_floatingip_v2.fip_prod_non.address
}
