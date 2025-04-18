# -----------------------------
# Auto Scaling Group Configuration
# -----------------------------
resource "aws_autoscaling_group" "asg_main" {
  name                      = "app-auto-scaling-group"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 3
  vpc_zone_identifier       = var.asg_subnets
  target_group_arns         = [var.app_target_group]
  health_check_type         = "ELB"

  launch_template {
    id      = var.launch_template
    version = "$Latest"
  }
}

# -----------------------------
# Scale-Up CloudWatch Alarm
# -----------------------------
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "cpu-usage-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Trigger scale-out when CPU > 70%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_main.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

# -----------------------------
# Scale-Up Policy
# -----------------------------
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.asg_main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# -----------------------------
# Scale-Down CloudWatch Alarm
# -----------------------------
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "cpu-usage-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Trigger scale-in when CPU < 30%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_main.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

# -----------------------------
# Scale-Down Policy
# -----------------------------
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.asg_main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# -----------------------------
# Input Variables
# -----------------------------
variable "asg_subnets" {
  type = list(string)
}

variable "app_target_group" {
  type = string
}

variable "launch_template" {
  type = string
}
