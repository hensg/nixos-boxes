variable "hcloud_token" {
  description = "Hetzner Cloud API token. Supply via TF_VAR_hcloud_token or a protected local tfvars file."
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Unique name for the new migration target."
  type        = string
  default     = "mail-web-next"
}

variable "server_type" {
  description = "Hetzner Cloud server type for the new host."
  type        = string
  default     = "cx23"
}

variable "server_image" {
  description = "Hetzner Cloud image for the new host."
  type        = string
  default     = "debian-13"
}

variable "location" {
  description = "Hetzner Cloud location. Confirm against the existing servers before apply."
  type        = string
  default     = "hel1"
}

variable "ssh_key_id" {
  description = "Existing Hetzner SSH key ID to attach to the new server."
  type        = number
  default     = 22516737
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs permitted to reach SSH. Narrow this to a stable admin IP when possible."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}
