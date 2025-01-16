# Data block to retrieve information about available Talos system extensions
# for a specified Talos version and filter them based on provided names.
data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.image.version
  filters = {
    names = var.image.extensions
  }
}

# Resource block to get the schematic ID for Talos image
resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
        }
      }
    }
  )
}
