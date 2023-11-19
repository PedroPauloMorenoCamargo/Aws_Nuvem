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
  name_prefix   = "pedro_ec2_launch_templ"
  image_id      = "ami-0fc5d935ebf8bc3bc" # To note: AMI is specific for each region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  user_data = base64encode(<<-EOF
              #!/bin/bash
              git clone https://github.com/PedroPauloMorenoCamargo/API.git
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

# CloudWatch metric alarm for high CPU utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "Pedro_HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Pedro_Scaling_Group.name
  }

  alarm_description = "This alarm monitors high CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up_policy.arn]

  tags = {
    Name = "HighCPUUtilization"
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "Pedro-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.Pedro_Scaling_Group.name
}
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "Pedro_LowCPUAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 20  # Adjust this threshold based on your requirements

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Pedro_Scaling_Group.name
  }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "Pedro-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.Pedro_Scaling_Group.name
}