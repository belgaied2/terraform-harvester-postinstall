resource "harvester_ssh_key" "capi_ssh_key" {
  name = var.ssh_key_name
  public_key = var.ssh_public_key
  description = "ssh key for capi"
  namespace = var.ssh_key_namespace 
}