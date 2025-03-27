output "template_id" {
  value = aws_launch_template.e2e-project-lt.id
}

output "asg_id" {
  value = aws_autoscaling_group.e2e-project-asg.id
}
