output "vpc_id" {
  value = aws_vpc.vpc_main.id
}

output "public_subnet1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet2_id" {
  value = aws_subnet.public_subnet_1a.id
}
output "private_subnet1_id" {
  value = aws_subnet.private_subnet_2.id
}

output "private_subnet2_id" {
  value = aws_subnet.private_subnet_2a.id
}

output "target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}

output "alb_id" {
  value = aws_lb.alb.id
}