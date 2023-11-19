resource "aws_db_instance" "mydb" {
  identifier           = "pedro-mysql-instance"
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "coxinha1234569"
  parameter_group_name = "default.mysql8.0"

  db_subnet_group_name    = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids  = [var.db_sg_id]
  skip_final_snapshot  = true  
  multi_az = true

  backup_retention_period = 7   # Retain backups for 7 days
  maintenance_window      = "Mon:00:00-Mon:03:00" 
  backup_window           = "04:00-07:00"  # Maintenance window on Mondays

  # Customize additional settings as needed
  # ...

  tags = {
    Environment = "Production"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "pedro-db-subnet-group"
  subnet_ids = [var.private_sub_1_id, var.private_sub_2_id]

  tags = {
    Name = "Pedro DB Subnet Group"
  }
}