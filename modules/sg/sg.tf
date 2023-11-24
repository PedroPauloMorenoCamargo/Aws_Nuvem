resource "aws_security_group" "sg_alb" {
  name   = "Pedro_sg_alb"
  vpc_id = var.vpc_id
  
  ingress {
    description      = "Allow http request from anywhere"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = var.cidr_all_blocks
    ipv6_cidr_blocks = var.cidr_all_ipv6_blocks
  }
  
  ingress {
    description      = "Allow https request from anywhere"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = var.cidr_all_blocks
    ipv6_cidr_blocks = var.cidr_all_ipv6_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_all_blocks
  }

}

resource "aws_security_group" "sg_ec2" {
  name   = "Pedro_sg_ec2"
  vpc_id = var.vpc_id
  description = "Allows inbound HTTP and SSH traffic"
  // Allow incoming traffic on port 80 from the Load Balancer's security group
  ingress {
    description     = "Allow incoming traffic from Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]  # Replace with your Load Balancer's security group ID
  }

  ingress {
    description     = "Allow ssh request from Load Balancer"
    protocol        = "tcp"
    from_port       = 22 # range of
    to_port         = 22 # port numbers
    cidr_blocks = var.cidr_all_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_all_blocks
  }

}

resource "aws_security_group" "sg_db" {
  name        = "PedroSQLAccessSG"
  description = "Allows inbound traffic on port 3306 from EC2 security group"
  vpc_id      = var.vpc_id 

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_all_blocks
  }
}
