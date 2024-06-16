terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
      version = "0.6.4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.30.0"
    }
    github = {
      source = "integrations/github"
      version = "~> 6.0"
    
    }
  }
}


provider "harvester" {
  kubeconfig = "${path.module}/../harvester-cl${var.cluster_number}-rke2.yaml"
  #TODO: Check what can be done with multiple clusters
}

provider "kubernetes" {
  config_path = "${path.module}/../harvester-cl${var.cluster_number}-rke2.yaml"
}

provider "github" {
  token = var.github_token
  
}