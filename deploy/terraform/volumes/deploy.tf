resource "openstack_blockstorage_volume_v2" "GrimoireLab_Elasticsearch_Volume" {
  region      = var.openstack_region
  name        = "GrimoireLab_ES_Volume"
  description = "Volume corresponding to the GrimoireLab instance"
  size        = 70
}
