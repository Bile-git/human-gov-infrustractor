variable "states" {
  description = "A list of state names"
  type        = list(string)
  default     = ["minnesota"]
}

variable "admin_ssh_cidr" {
  description = "Trusted administrator public IPv4 CIDR allowed to connect to EC2 over SSH, for example 203.0.113.10/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_ssh_cidr, 0)) && can(regex("/32$", var.admin_ssh_cidr))
    error_message = "admin_ssh_cidr must be a single IPv4 address with a /32 mask."
  }
}
