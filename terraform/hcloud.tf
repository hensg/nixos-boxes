variable "hcloud_token" {}

provider "hcloud" {
  token = "${var.hcloud_token}"
}

data "hcloud_server" "mailserver" {
  name = "mailserver"
}

data "hcloud_server" "website" {
  name = "website"
}

#resource "hcloud_server" "dummy-srv" {
#  name        = "dummy-srv"
#  image       = "debian-12"
#  server_type = "cx22"
#  datacenter_name = "hel1-dc2"
#}

module "talos" {
  source  = "hcloud-talos/talos/hcloud"
  version = "v2.11.9"

  talos_version = "v1.8.3"
  kubernetes_version = "1.29.7"
  cilium_version = "1.15.7"

  hcloud_token = "${var.hcloud_token}"

  cluster_name     = "k8s.hensg.dev"
  cluster_domain   = "cluster.k8s.hensg.dev.local"
  cluster_api_host = "kube.hensg.dev"

  firewall_use_current_ip = true

  datacenter_name = "hel1-dc2"

  control_plane_count       = 1
  control_plane_server_type = "cax11"

  worker_count       = 1
  worker_server_type = "cax21"

  network_ipv4_cidr = "10.0.0.0/16"
  node_ipv4_cidr    = "10.0.1.0/24"
  pod_ipv4_cidr     = "10.0.16.0/20"
  service_ipv4_cidr = "10.0.8.0/21"
}


