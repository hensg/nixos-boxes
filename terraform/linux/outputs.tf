output "server_id" {
  description = "Hetzner server ID for the new Linux host."
  value       = hcloud_server.mail_web.id
}

output "public_ipv4" {
  description = "Public IPv4 address for Ansible inventory and DNS planning."
  value       = hcloud_server.mail_web.ipv4_address
}

output "public_ipv6" {
  description = "Public IPv6 address for DNS planning."
  value       = hcloud_server.mail_web.ipv6_address
}
