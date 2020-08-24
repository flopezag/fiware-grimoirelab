data "openstack_networking_network_v2" "grimoirelab" {
  name = var.external_pool
}