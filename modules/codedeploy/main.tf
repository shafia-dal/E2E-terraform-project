resource "aws_codedeploy_app" "e2e-codedeploy-app" {
  name = var.codedeploy_app
  compute_platform = "Server"
}
data "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-e2e-role"
  # arn = "arn:aws:iam::091846656105:role/codedeploy-e2e-role"
}
resource "aws_codedeploy_deployment_group" "e2e-codedeployment-group" {
  app_name              = aws_codedeploy_app.e2e-codedeploy-app.name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = data.aws_iam_role.codedeploy_role.arn

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  autoscaling_groups = [ 
    var.autoscaling_groups
   ]

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "nodeapp-server"
    }
  }
}
# resource "aws_iam_role" "e2e_codedeploy_role" {
#   name = "e2e-codedeploy-role"
#   assume_role_policy = <<EOF
#   {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codedeploy.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
# resource "aws_iam_role_policy" "e2e_codedeploy_iam_policy" {
#   role = "${aws_iam_role.e2e_codedeploy_role.name}"

#   policy = <<-POLICY
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "autoscaling:CompleteLifecycleAction",
#                 "autoscaling:DeleteLifecycleHook",
#                 "autoscaling:DescribeAutoScalingGroups",
#                 "autoscaling:DescribeLifecycleHooks",
#                 "autoscaling:PutLifecycleHook",
#                 "autoscaling:RecordLifecycleActionHeartbeat",
#                 "autoscaling:CreateAutoScalingGroup",
#                 "autoscaling:CreateOrUpdateTags",
#                 "autoscaling:UpdateAutoScalingGroup",
#                 "autoscaling:EnableMetricsCollection",
#                 "autoscaling:DescribePolicies",
#                 "autoscaling:DescribeScheduledActions",
#                 "autoscaling:DescribeNotificationConfigurations",
#                 "autoscaling:SuspendProcesses",
#                 "autoscaling:ResumeProcesses",
#                 "autoscaling:AttachLoadBalancers",
#                 "autoscaling:AttachLoadBalancerTargetGroups",
#                 "autoscaling:PutScalingPolicy",
#                 "autoscaling:PutScheduledUpdateGroupAction",
#                 "autoscaling:PutNotificationConfiguration",
#                 "autoscaling:PutWarmPool",
#                 "autoscaling:DescribeScalingActivities",
#                 "autoscaling:DeleteAutoScalingGroup",
#                 "ec2:DescribeInstances",
#                 "ec2:DescribeInstanceStatus",
#                 "ec2:TerminateInstances",
#                 "tag:GetResources",
#                 "sns:Publish",
#                 "cloudwatch:DescribeAlarms",
#                 "cloudwatch:PutMetricAlarm",
#                 "elasticloadbalancing:DescribeLoadBalancerAttributes",
#                 "elasticloadbalancing:DescribeTargetGroupAttributes",
#                 "elasticloadbalancing:DescribeLoadBalancers",
#                 "elasticloadbalancing:DescribeInstanceHealth",
#                 "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
#                 "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
#                 "elasticloadbalancing:DescribeTargetGroups",
#                 "elasticloadbalancing:DescribeTargetHealth",
#                 "elasticloadbalancing:RegisterTargets",
#                 "elasticloadbalancing:DeregisterTargets"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Action": [
#                 "s3:GetObject",
#                 "s3:ListBucket"
#             ],
#             "Effect": "Allow",
#             "Resource": [
#                 "arn:aws:s3:::${var.artifect_bucket_arn}",
#                 "arn:aws:s3:::${var.artifect_bucket_arn}/*"
#             ]
#         },
#         {
#             "Action": [
#                 "ecr:GetAuthorizationToken",
#                 "ecr:BatchCheckLayerAvailability",
#                 "ecr:GetDownloadUrlForLayer",
#                 "ecr:BatchGetImage"
#             ],
#             "Effect": "Allow",
#             "Resource": "*"
#         },
#         {
#             "Action":"EC2:*",
#             "Effect": "Allow",
#             "Resource": "*"
#         }
#     ]
#   }
#   POLICY
# }
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "ec2:Describe*",
#                 "ec2:Get*",
#                 "ec2:ReportInstanceStatus",
#                 "ec2:TerminateInstances",
#                 "ec2:StopInstances",
#                 "ec2:StartInstances",
#                 "ec2:RebootInstances",
#                 "ec2:AssociateAddress",
#                 "ec2:DeregisterImage",
#                 "ec2:ModifyImageAttribute",
#                 "ec2:ModifyInstanceAttribute",
#                 "ec2:RunInstances",
#                 "ec2:CreateTags",
#                 "ec2:DeleteTags"
#             ],
#             "Effect": "Allow",
#             "Resource": "*"
#         },
#         {
#             "Action": [
#                 "s3:GetObject",
#                 "s3:ListBucket"
#             ],
#             "Effect": "Allow",
#             "Resource": [
#                 "arn:aws:s3:::${var.artifect_bucket_arn}",
#                 "arn:aws:s3:::${var.artifect_bucket_arn}/*"
#             ]
#         },
#         {
#             "Action": [
#                 "ecr:GetAuthorizationToken",
#                 "ecr:BatchCheckLayerAvailability",
#                 "ecr:GetDownloadUrlForLayer",
#                 "ecr:BatchGetImage"
#             ],
#             "Effect": "Allow",
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }
