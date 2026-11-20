variable "state_name" {
  description = "The name of the US state"
  type        = string
}

variable "admin_ssh_cidr" {
  description = "Trusted administrator public IPv4 address in /32 CIDR notation"
  type        = string
}
