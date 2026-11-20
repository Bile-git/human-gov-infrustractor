variable "states" {
  description = "A list of state names"
  type        = list(string)
  default     = ["minnesota"]
}

variable "admin_ssh_cidr" {
  description = "Trusted administrator public IPv4 CIDR allowed to connect to EC2 over SSH, for example 203.0.113.10/32"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.admin_ssh_cidr)) && can(cidrhost(var.admin_ssh_cidr, 0))
    error_message = "admin_ssh_cidr must be a single IPv4 address with a /32 mask."
  }
}
