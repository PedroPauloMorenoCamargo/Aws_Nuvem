variable "private_subnets_ids" {
  description = "Redes_Privadas_Ids"
  type        = list(string)
}

variable "ec2_sg_id" {
  description = "ID Security Group das EC2"
  type        = string
}