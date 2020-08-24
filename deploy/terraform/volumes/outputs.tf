#
# show the Public and Private IP addresses of the virtual machines
#
output "Elasticsearch_Volume"	{
	value = openstack_blockstorage_volume_v2.GrimoireLab_Elasticsearch_Volume.id
}
