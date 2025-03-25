
resource "aws_autoscaling_group" "nextCloud-asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"] # Replace with your subnet IDs

  launch_template {
    id      = aws_launch_template.nextCloud-asg.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.nextCloud-asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.nextCloud-asg.name
}  

output "autoscaling_group_name" {
  value = aws_autoscaling_group.nextCloud-asg.name
}
