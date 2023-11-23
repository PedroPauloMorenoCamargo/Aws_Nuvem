# VPC
resource "aws_vpc" "vpc_main" {
  cidr_block = var.cidr_vpc
  tags = {
    Name = "Pedro-vpc"
  }
}

# Creating 1st public subnet 
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = element(var.public_subnet_cidrs,0)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs,0)
  tags = {
    Name = "Pedro_public_subnet_1"
  }
}
# Creating 2nd public subnet 
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = element(var.public_subnet_cidrs,1)
  map_public_ip_on_launch = true 
  availability_zone       = element(var.azs,1)
  tags = {
    Name = "Pedro_public_subnet_2"
  }
}
# Creating 1st private subnet 
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = element(var.private_subnet_cidrs,0)
  map_public_ip_on_launch = false
  availability_zone       = element(var.azs,0)
  tags = {
    Name = "Pedro_private_subnet_1"
  }
}

# Creating 2nd private subnet 
resource "aws_subnet" "private_subnet_2a" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = element(var.private_subnet_cidrs,1)
  map_public_ip_on_launch = false  
  availability_zone       = element(var.azs,1)
  tags = {
    Name = "Pedro_private_subnet_2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name = "Pedro_IG"
  }
}


# route table for public subnet - connecting to Internet gateway
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = var.cidr_all_blocks
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Rota_Publica"
  }
}


# associate the route table with public subnet 1
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.rt_public.id
}

# associate the route table with public subnet 1
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.rt_public.id
}


# Elastic IP for NAT gateway
resource "aws_eip" "eip1" {
  depends_on = [aws_internet_gateway.gw]
  vpc        = true
  tags = {
    Name = "Pedro_EIP1_for_NAT"
  }
}

# NAT gateway for private subnets 
# (for the private subnet to access internet - eg. ec2 instances downloading softwares from internet)
resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet_1.id # nat should be in public subnet
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "Pedro-nat-gw-1"
  }
}

# Elastic IP for NAT gateway
resource "aws_eip" "eip2" {
  depends_on = [aws_internet_gateway.gw]
  vpc        = true
  tags = {
    Name = "Pedro_EIP2_for_NAT"
  }
}


# NAT gateway for private subnets 
# (for the private subnet to access internet - eg. ec2 instances downloading softwares from internet)
resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet_1a.id # nat should be in public subnet
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "Pedro-nat-gw-2"
  }
}



# route table - connecting to NAT
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block     = var.cidr_all_blocks
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = {
    Name = "private-route-table-1"
  }
}


# route table - connecting to NAT
resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block     = var.cidr_all_blocks
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id
  }
  tags = {
    Name = "Pedro-private-route-table-2"
  }
}

// Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.private_subnet_2a.id
  route_table_id = aws_route_table.private_rt_2.id
}


resource "aws_lb" "alb" {
  name               = "Pedro-lb-asg"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_1a.id]
  depends_on         = [aws_internet_gateway.gw]
}


# Creating a target group for the ALB
resource "aws_lb_target_group" "alb_target_group" {
  name     = "Pedro-target-group"
  port     = 80  # Port on which your instances are serving traffic
  protocol = "HTTP"  # Protocol used by your instances

  vpc_id   = aws_vpc.vpc_main.id # Replace with your VPC ID

  health_check {
    path                = "/"  # Health check path for your application
    interval            = 30   # Health check interval in seconds
    protocol            = "HTTP"  # Health check protocol
    port                = "traffic-port"  # Port used for health checks
    timeout             = 10   # Health check timeout in seconds
    healthy_threshold   = 2    # Number of consecutive successful health checks required to mark the target healthy
    unhealthy_threshold = 2    # Number of consecutive failed health checks required to mark the target unhealthy
  }

  tags = {
    Name = "PedroTargetGroup"
    Environment = "Production"
    # Add more tags as needed
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}