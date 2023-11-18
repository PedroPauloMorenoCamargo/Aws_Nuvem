resource "tls_private_key" "Par_Chave" {
 algorithm = "RSA"
}
resource "aws_key_pair" "generated_key" {
 key_name = "Pedro_Par_Chave"
 public_key = "${tls_private_key.Par_Chave.public_key_openssh}"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}
resource "local_file" "key" {
 content = "${tls_private_key.Par_Chave.private_key_pem}"
 filename = "Pedro_Par_Chave.pem"
 file_permission ="0400"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}



# ASG with Launch template
resource "aws_launch_template" "ec2_launch_templ" {
  name_prefix   = "Pedro_ec2_launch_templ"
  image_id      = "ami-00c39f71452c08778" # To note: AMI is specific for each region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
   user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              echo "<h1>Hello, World! $(hostname -f)</h1>" > /var/www/html/index.html
              systemctl enable httpd
              systemctl start httpd
              EOF
    )

  vpc_security_group_ids = [var.ec2_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App-instance" # Name for the EC2 instances
    }
  }
}


resource "aws_autoscaling_group" "Pedro_Scaling_Group" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = [var.private_sub1_id, var.private_sub2_id]  # Assuming these are your private subnets

   # Connect to the target group
  target_group_arns = [var.target_group_arn]
  launch_template {
    id = aws_launch_template.ec2_launch_templ.id
    version = "$Latest"  # Use specific version or $Latest for the latest version of the template
  }

}