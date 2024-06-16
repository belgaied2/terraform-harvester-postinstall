resource "harvester_image" "sles15sp5-default" {
  name      = var.image
  namespace = var.image_namespace

  display_name = var.image
  source_type  = "download"
  url          = var.image_url
}
