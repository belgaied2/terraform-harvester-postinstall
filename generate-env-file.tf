locals {
  harvester_url = data.local_file.harvester_kubeconfig.content != "" ? yamldecode(file("${path.module}/../harvester-cl${var.cluster_number}-rke2.yaml"))["clusters"][0]["cluster"]["server"] : yamldecode(file("${path.module}/../harvester-cl${var.cluster_number}-rke2.yaml"))["clusters"][0]["cluster"]["server"]
  harvester_host = replace(replace(local.harvester_url, "https://", ""), ":6443", "")
}

data "local_file" "harvester_kubeconfig" {
  filename = "${path.module}/../harvester-cl${var.cluster_number}-rke2.yaml"

  depends_on = [
    harvester_image.sles15sp5-default
  ] 
}


data "external" "gen_env_file" {
  
  program = [ "bash", "-c", "NAME=harvester-cl${var.cluster_number} KUBECONFIG=../$NAME-rke2.yaml PART_ID=${var.github_branch} scripts/get_cloud-config.sh"]
  
}


resource "github_repository_file" "harvester_rc" {
  repository = "susecon-participant-repo"
  file = "./capi-cluster-rc"
  content   = <<EOT
export CLUSTER_NAME=test-rk
export NAMESPACE=example-rke2
export KUBERNETES_VERSION=v1.26.6
export SSH_KEYPAIR=${var.ssh_key_namespace}/${var.ssh_key_name}
export VM_IMAGE_NAME=${var.image_namespace}/${var.image}
export CONTROL_PLANE_MACHINE_COUNT=3
export WORKER_MACHINE_COUNT=2
export IP_POOL_NAME=pool-1
export VM_DISK_SIZE=${var.capi_vm_disk_size}
export RANCHER_TURTLES_LABEL='    cluster-api.cattle.io/rancher-auto-import: "true"'
export HARVESTER_ENDPOINT=https://${local.harvester_host}:6443
export VM_NETWORK=harvester-public/vlan-${var.vlan_ids[0]}
export HARVESTER_KUBECONFIG_B64=${data.external.gen_env_file.result.harvester-kubeconfig}
export CLOUD_CONFIG_SECRET=${data.external.gen_env_file.result.cloud-config}
  EOT
  overwrite_on_create = true
  branch    = var.github_branch
  commit_message   = "Add capi-cluster-rc"
  commit_author = "Mohamed Belgaied"
  commit_email = "mohamed.belgaied@suse.com"

  depends_on = [ data.external.gen_env_file , harvester_virtualmachine.dhcpd ]
  
  
}
