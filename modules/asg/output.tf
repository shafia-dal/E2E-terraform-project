output "template_id" {
  value = aws_launch_template.e2e-project-lt.id
}
output "asg_id" {
  value = aws_autoscaling_group.e2e-project-asg.id
}
output "rendered_user_data" {
  value = data.template_file.instance_provision.rendered
}
output "asg_name" {
  value = aws_autoscaling_group.e2e-project-asg.name
}