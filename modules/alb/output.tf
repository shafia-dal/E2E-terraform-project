output "alb_dns_name" {
  value       = aws_lb.alb_loadbalancer.dns_name
}

output "target_group_arns" {
  value       = aws_lb_target_group.alb-tg.arn
}

# Output the ALB and Target Group ARNs
output "alb_arn" {
  value       = aws_lb.alb_loadbalancer.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}