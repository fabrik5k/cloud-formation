# outputs.tf

output "load_balancer_dns" {
  description = "DNS do Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "db_endpoint_address" {
  description = "Endpoint do RDS MySQL"
  value       = aws_db_instance.main.address
}

output "environment" {
  description = "Ambiente implantado"
  value       = var.environment
}

