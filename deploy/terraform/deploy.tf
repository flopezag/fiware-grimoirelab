#
# Create a security group, ports 22, 5601, and 8000
#
resource "openstack_compute_secgroup_v2" "grimoirelab" {
    region = ""
    name = "grimoirelab"
    description = "Security Group Via Terraform"
    rule {
        from_port = 5601
        to_port = 5601
        ip_protocol = "tcp"
        cidr = "0.0.0.0/0"
    }
    rule {
        from_port = 8000
        to_port = 8000
        ip_protocol = "tcp"
        cidr = "0.0.0.0/0"
    }
    rule {
        from_port = 22
        to_port = 22
        ip_protocol = "tcp"
        cidr = "0.0.0.0/0"
    }
}

#
# Create a keypair
#
resource "openstack_compute_keypair_v2" "gl_keypair" {
  region = var.openstack_region
  name = "tf_grimoirelab_keypair"
}


#
# Create network interface
#
resource "openstack_networking_network_v2" "grimoirelab" {
  name = "grimoirelab"
  admin_state_up = "true"
  region = var.openstack_region
}

resource "openstack_networking_subnet_v2" "grimoirelab" {
  name = "grimoirelab"
  network_id = openstack_networking_network_v2.grimoirelab.id
  cidr = "10.0.0.0/24"
  ip_version = 4
  dns_nameservers = ["8.8.8.8","8.8.4.4"]
  region = var.openstack_region
}

resource "openstack_networking_router_v2" "grimoirelab" {
  name = "grimoirelab"
  admin_state_up = "true"
  region = var.openstack_region
  external_network_id = data.openstack_networking_network_v2.grimoirelab.id
}

resource "openstack_networking_router_interface_v2" "terraform" {
  router_id = openstack_networking_router_v2.grimoirelab.id
  subnet_id = openstack_networking_subnet_v2.grimoirelab.id
  region = var.openstack_region
}

#
# Create an Openstack Floating IP for the Main VM
#
resource "openstack_compute_floatingip_v2" "fip_grimoirelab" {
    region = var.openstack_region
    pool = "public-ext-net-01"
}


#
# Create the VM Instances for Digital Enabler
#
resource "openstack_compute_instance_v2" "grimoirelab" {
  name = "grimoirelab"
  image_name = var.image
  availability_zone = var.availability_zone
  flavor_name = var.openstack_flavor
  key_pair = openstack_compute_keypair_v2.gl_keypair.name
  security_groups = [openstack_compute_secgroup_v2.grimoirelab.name]
  network {
    uuid = openstack_networking_network_v2.grimoirelab.id
  }
}

#
# Associate public IPs to the VMs
#
resource "openstack_compute_floatingip_associate_v2" "fip_grimoirelab" {
  floating_ip = openstack_compute_floatingip_v2.fip_grimoirelab.address
  instance_id = openstack_compute_instance_v2.grimoirelab.id
}

#
# Attaching volumes to the instances
#
#resource "openstack_compute_volume_attach_v2" "va_grimoirelab" {
#  region = var.openstack_region
#  instance_id = openstack_compute_instance_v2.grimoirelab.id
#  volume_id   = var.openstack_grimoirelab_volume_id
#}

locals {
  template_keypair_init = templatefile("${path.module}/templates/keypair.tpl", {
    keypair = openstack_compute_keypair_v2.gl_keypair.private_key
  }
  )

  template_inventory_init = templatefile("${path.module}/templates/ansible_inventory.tpl", {
    connection_strings = join("\n",
           formatlist("%s ansible_ssh_host=%s ansible_ssh_user=ubuntu ansible_connection=ssh",
                        openstack_compute_instance_v2.grimoirelab.name,
                        openstack_compute_floatingip_v2.fip_grimoirelab.address))

    list_nodes = openstack_compute_instance_v2.grimoirelab.name
  }
  )

}

resource "local_file" "keypair_file" {
  content = local.template_keypair_init
  filename = "../ansible/keypair"
  file_permission = "0600"
}

resource "local_file" "ansible_inventory" {
  content = local.template_inventory_init
  filename = "../ansible/inventory.ini"
  file_permission = "0600"
}