resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.env_code}-launch-config"
  image_id             = data.aws_ami.linux-image.id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.private.id]
  iam_instance_profile = aws_iam_instance_profile.main.name
  user_data            = file("user-data.sh")

  key_name = "ansible"
}

resource "aws_autoscaling_group" "main" {
  name             = var.env_code
  min_size         = 2
  max_size         = 5
  desired_capacity = 2

  target_group_arns    = [aws_lb_target_group.main.arn]
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = data.terraform_remote_state.layer1.outputs.subnet_id_private


  tag {
    key                 = "Name"
    value               = "${var.env_code}-asg"
    propagate_at_launch = true
  }
}




