output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb_loadbalancer.dns_name
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = aws_lb_target_group.alb-tg.arn
}

# Output the ALB and Target Group ARNs
output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.alb_loadbalancer.arn
}


output "security_group_ids" {
  value = aws_security_group.alb_sg.id
}