resource "tls_private_key" "Par_Chave" {
 algorithm = "RSA"
}
resource "aws_key_pair" "generated_key" {
 key_name = "Par_Chave"
 public_key = "${tls_private_key.Par_Chave.public_key_openssh}"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}
resource "local_file" "key" {
 content = "${tls_private_key.Par_Chave.private_key_pem}"
 filename = "Par_Chave.pem"
 file_permission ="0400"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}

#Pega a versão do Ubuntu para a instância
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# Create an EC2 instance
resource "aws_instance" "App_EC2" {
  ami           = "ami-0533f2ba8a1995cf9"
  instance_type = "t2.micro"  # Replace with your desired instance type
  key_name      = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
  #!/bin/bash -ex

  amazon-linux-extras install nginx1 -y
  echo "<h1>$(curl https://api.kanye.rest/?format=text)</h1>" >  /usr/share/nginx/html/index.html 
  systemctl enable nginx
  systemctl start nginx
  EOF

  subnet_id     = element(aws_subnet.public_subnets[*].id, 0)  # Use a public subnet for the instance
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  
  tags = {
    Name = "App_EC2"
  }
}