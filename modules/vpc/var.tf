variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "cidr_vpc" {
  type        = string
  description = "Availability Zones"
  default     = "10.0.0.0/16"
}

variable "cidr_all_blocks" {
  type        = string
  description = "Availability Zones"
  default     = "0.0.0.0/0"
}

variable "alb_sg_id"{
  type        = string
  description = "Load Balancer SG ID"
}