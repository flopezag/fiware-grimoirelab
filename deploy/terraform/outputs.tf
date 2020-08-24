#
# show the Public and Private IP addresses of the virtual machines
#
output "GrimoireLab"	{
	value = "${openstack_compute_floatingip_v2.fip_grimoirelab.address} initialized with success"
}

output "Keypair" {
	value = openstack_compute_keypair_v2.gl_keypair.private_key
}
