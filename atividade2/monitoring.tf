# monitoring.tf

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-HighCPU"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 75
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "CPU > 75% por 5 minutos"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "${var.environment}-DBConnections"
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 50
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "Conexões no RDS > 50"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

