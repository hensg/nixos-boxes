terraform {
  required_version = ">= 1.6.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.49.1, < 2.0.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_key" "admin" {
  id = var.ssh_key_id
}

resource "hcloud_firewall" "mail_web" {
  name = "${var.server_name}-firewall"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ssh_allowed_cidrs
    description = "SSH administration"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
    description = "HTTP and ACME validation"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
    description = "HTTPS website"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "25"
    source_ips = ["0.0.0.0/0", "::/0"]
    description = "SMTP server-to-server mail"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "465"
    source_ips = ["0.0.0.0/0", "::/0"]
    description = "SMTPS submission"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "587"
    source_ips = ["0.0.0.0/0", "::/0"]
    description = "SMTP submission"
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "993"
    source_ips = ["0.0.0.0/0", "::/0"]
    description = "IMAPS"
  }
}

resource "hcloud_server" "mail_web" {
  name        = var.server_name
  server_type = var.server_type
  image       = var.server_image
  location    = var.location
  ssh_keys    = [data.hcloud_ssh_key.admin.id]
  firewall_ids = [
    hcloud_firewall.mail_web.id,
  ]
  backups = false

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  user_data = <<-CLOUD_CONFIG
    #cloud-config
    package_update: true
    packages:
      - python3
      - sudo
  CLOUD_CONFIG
}
