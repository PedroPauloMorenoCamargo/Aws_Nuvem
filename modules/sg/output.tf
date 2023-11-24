
output "ec2_sg_id" {
  value = aws_security_group.sg_ec2.id
}


output "alb_sg_id" {
  value = aws_security_group.sg_alb.id
}



output "db_sg_id" {
  value = aws_security_group.sg_db.id
}