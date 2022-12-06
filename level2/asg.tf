data "aws_ami" "linux-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.image_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


module "ec2autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = var.env_code
  min_size                  = 2
  max_size                  = 5
  desired_capacity          = 4
  health_check_grace_period = 30
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.terraform_remote_state.layer1.outputs.subnet_id_private
  target_group_arns         = module.elb.target_group_arns
  force_delete              = true

  launch_template_name   = var.env_code
  update_default_version = true

  image_id        = data.aws_ami.linux-image.id
  instance_type   = "t2.micro"
  key_name        = "ansible"
  security_groups = [module.external_sg.security_group_id]
  user_data       = filebase64("user-data.sh")


  create_iam_instance_profile = true
  iam_role_name               = var.env_code
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for Sessions Manager"
  iam_role_tags = {
    CustomIamRole = "No"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

