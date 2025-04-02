resource "aws_iam_role" "asg_instance_role" {
  name = "asg-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "asg_instance_policy_attach" {
  name       = "asg-instance-policy-attachment"
  roles      = [aws_iam_role.asg_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"  # Adjust policy as needed
}
resource "aws_iam_instance_profile" "asg_instance_profile" {
  name = "asg-instance-profile"
  role = aws_iam_role.asg_instance_role.name
}
