terraform {
  required_version = ">= 1.3.3"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.35.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_key" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "hcloud_token" {
  type = string
}

provider "hcloud" {
  token = local.hcloud_token
}

provider "helm" {
  kubernetes {
    host                   = module.kube-hetzner.kubeconfig.host
    client_certificate     = module.kube-hetzner.kubeconfig.client_certificate
    client_key             = module.kube-hetzner.kubeconfig.client_key
    cluster_ca_certificate = module.kube-hetzner.kubeconfig.cluster_ca_certificate
  }
}

provider "kubernetes" {
  host                   = module.kube-hetzner.kubeconfig.host
  client_certificate     = module.kube-hetzner.kubeconfig.client_certificate
  client_key             = module.kube-hetzner.kubeconfig.client_key
  cluster_ca_certificate = module.kube-hetzner.kubeconfig.cluster_ca_certificate
}

provider "kubectl" {
  host                   = module.kube-hetzner.kubeconfig.host
  client_certificate     = module.kube-hetzner.kubeconfig.client_certificate
  client_key             = module.kube-hetzner.kubeconfig.client_key
  cluster_ca_certificate = module.kube-hetzner.kubeconfig.cluster_ca_certificate
  load_config_file       = false
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}