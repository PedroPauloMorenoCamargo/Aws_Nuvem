variable "ec2_sg_id" {
  description = "ID Security Group das EC2"
  type        = string
}

variable "public_sub1_id" {
  description = "public_sub1_id"
  type        = string
}

variable "public_sub2_id" {
  description = "public_sub2_id"
  type        = string
}

variable "target_group_arn" {
  description = "target_group_arn"
  type        = string
}

variable "endpoint" {
  description = "DB endpoint"
  type        = string
}

variable "alb_id" {
  description = "ALB Name"
  type        = string
}

variable "iam_profile_name" {
  description = "Profile Name"
  type        = string
}
