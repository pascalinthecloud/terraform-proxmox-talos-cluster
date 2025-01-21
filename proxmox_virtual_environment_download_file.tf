# dowload talos image to datastore 
resource "proxmox_virtual_environment_download_file" "this" {
  for_each                = local.nodes
  node_name               = each.key
  content_type            = "iso"
  datastore_id            = var.image.proxmox_datastore
  file_name               = "talos-${var.image.version}.img"
  url                     = "${var.image.factory_url}/image/${talos_image_factory_schematic.this.id}/${var.image.version}/${var.image.platform}-${var.image.arch}.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
  overwrite_unmanaged     = true #overwriting image when image is already existing but not managed by terraform (for example when ressources moved from state)
}
