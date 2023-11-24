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

  iam_instance_profile {
    name = var.iam_profile_name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              
              sudo apt-get update
              sudo apt-get install -y python3-pip python3-venv git authbind awscli

              
              git clone https://github.com/PedroPauloMorenoCamargo/API.git /home/ubuntu/API
              cd /home/ubuntu/API

              
              sudo chown -R ubuntu:ubuntu ~/API
              python3 -m venv env
              source env/bin/activate
              sudo chown -R ubuntu /home/ubuntu/API/env
              pip install -r requirements.txt

              
              export HOST=${var.endpoint}
              export USER=root
              export KEY=penis12345678
              INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              export INSTANCE=$INSTANCE_ID


              sudo touch /etc/authbind/byport/80
              sudo chmod 500 /etc/authbind/byport/80
              sudo chown ubuntu /etc/authbind/byport/80

              starting the app
              authbind --deep uvicorn app.main:app --host 0.0.0.0 --port 80
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
  desired_capacity     = 4
  max_size             = 8
  min_size             = 2
  vpc_zone_identifier  = [var.public_sub1_id, var.public_sub2_id]  # Assuming these are your private subnets
  health_check_type = "EC2"
  health_check_grace_period = 300
  force_delete = true
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
  alarm_actions             = [aws_autoscaling_policy.scale_down_policy.arn]
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


resource "aws_autoscaling_policy" "scale_up_down_tracking" {
  policy_type = "TargetTrackingScaling"
  name = "scale-up-down-request-count"
  autoscaling_group_name = aws_autoscaling_group.Pedro_Scaling_Group.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${split("/", var.alb_id)[1]}/${split("/", var.alb_id)[2]}/${split("/", var.alb_id)[3]}/targetgroup/${split("/", var.target_group_arn )[1]}/${split("/", var.target_group_arn )[2]}"
    }
    target_value = 250
    
  }

  lifecycle {
    create_before_destroy = true 
  }
}