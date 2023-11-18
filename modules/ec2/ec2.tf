#Cria Par de Chaves
resource "tls_private_key" "Par_Chave" {
 algorithm = "RSA"
}
resource "aws_key_pair" "generated_key" {
 key_name = "Par_Chave_Pedro"
 public_key = "${tls_private_key.Par_Chave.public_key_openssh}"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}
#Salva Chave Privada
resource "local_file" "key" {
 content = "${tls_private_key.Par_Chave.private_key_pem}"
 filename = "Par_Chave_Pedro.pem"
 file_permission ="0400"
 depends_on = [
  tls_private_key.Par_Chave
 ]
}



resource "aws_autoscaling_group" "Pedro_Scaling_Group" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = var.private_subnets_ids   # Assuming these are your private subnets


  launch_template {
    id = aws_launch_template.Pedro_LT.id
    version = "$Latest"  # Use specific version or $Latest for the latest version of the template
  }

}


resource "aws_launch_template" "Pedro_LT" {
  name_prefix   = "Pedro-Launch-Template"
  image_id      = "ami-0b0ea68c435eb488d"  
  instance_type = "t2.micro"      
  vpc_security_group_ids = [var.ec2_sg_id]
  key_name  = aws_key_pair.generated_key.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              EOF
  )
}


# Recurso para criar um alarme no CloudWatch
resource "aws_cloudwatch_metric_alarm" "Pedro_cpu_alarm_70" {
  alarm_name          = "Pedro_CPUUtilizationAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU Utilization is greater than or equal to 70% for 2 periods"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Pedro_Scaling_Group.name
  }

  alarm_actions = [aws_autoscaling_policy.Pedro_scale_out_policy.arn]
}

# Recurso para criar um alarme no CloudWatch
resource "aws_cloudwatch_metric_alarm" "Pedro_cpu_alarm_25" {
  alarm_name          = "Pedro_CPUUtilizationAlarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 25
  alarm_description   = "Alarm when CPU Utilization is greater than or equal to 70% for 2 periods"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Pedro_Scaling_Group.name
  }

  alarm_actions = [aws_autoscaling_policy.Pedro_scale_in_policy.arn]
}

# Scaling policy to scale out (increase instances)
resource "aws_autoscaling_policy" "Pedro_scale_out_policy" {
  name                   = "Pedro-scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.Pedro_Scaling_Group.name  # Replace with your Auto Scaling Group name

}

# Scaling policy to scale in (decrease instances)
resource "aws_autoscaling_policy" "Pedro_scale_in_policy" {
  name                   = "Pedro-scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name =  aws_autoscaling_group.Pedro_Scaling_Group.name # Replace with your Auto Scaling Group name

}