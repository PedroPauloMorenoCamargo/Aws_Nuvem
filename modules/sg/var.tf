variable "vpc_id" {
  description = "ID VPC"
  type        = string
}

variable "cidr_all_blocks" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["0.0.0.0/0"]
}

variable "cidr_all_ipv6_blocks" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["::/0"]
}