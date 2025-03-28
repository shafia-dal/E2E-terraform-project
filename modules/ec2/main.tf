resource "aws_instance" "e2e-project" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  security_groups        = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = var.instance_name
  }
user_data                   = data.template_file.instance_provision.rendered

}
data "template_file" "instance_provision" {
  template = file("${path.module}/userscipt.sh")
}

# data "template_file" "instance_provision" {
#   template = file("${path.module}/../scripts/instance_provisioning.bash")
# }