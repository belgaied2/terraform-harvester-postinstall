variable "image_namespace" {
  description = "namespace of the image"
  type = string
  default = "default" 
}

variable "image" {
  description = "name of the image"
  type = string
  default = "sles15sp5-default" 
}

variable "image_url" {
  description = "url of the image"
  type = string
  default = "https://download.opensuse.org/repositories/home:/mohamed.belgaied:/branches:/SUSE:/Templates:/Images:/SLE-15-SP5/images/SLES15-SP5-Minimal-VM.x86_64.qcow2"  
}

variable "num_of_vlans" {
  description = "number of vlans"
  type = number
  default = 4
  
}

variable "cluster_number" {
  description = "number of the cluster"
  type = number
  default = 0
  
}

variable "ssh_key_name" {
  description = "name of the ssh key"
  type = string
  default = "capi_ssh_key"
  
}

variable "ssh_public_key" {
  description = "public key of the ssh key"
  type = string

  sensitive = true  
}

variable "ssh_key_namespace" {
  description = "namespace of the ssh key"
  type = string
  default = "default"
  
}

variable "equinix_private_ipv4_subnets" {
  
  description = "private ipv4 subnet"
  type = list(string)
  default = []
}

variable "additional_runcmd_data" {
  description = "additional runcmd data"
  type = string
  default = "" 
}

variable "vlan_ids" {
  description = "vlan ids"
  type = list(number)
  default = [1]
  
}

variable "equinix_public_ipv4_subnet" {
  description = "public ipv4 subnet"
  type = string
  default = ""
  
}

variable "node_ips" {
  description = "Harvester node ips"
  type = list(string)
  default = []
}

variable "github_token" {
  description = "github token"
  type = string
  
}

variable "github_branch" {
  description = "github branch"
  type = string
  
}

variable "capi_vm_disk_size" {
  description = "capi vm disk size"
  type = string
  default = "20Gi"
  
}

variable "tailscale_authkey" {
  description = "tailscale authkey"
  type = string
  default = ""
  
}
