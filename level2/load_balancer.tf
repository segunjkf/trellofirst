resource "aws_security_group" "load_balanacer-sg" {
  name        = "${var.env_code}-load-balancer"
  description = "Allow tcp to the load balanacer"
  vpc_id      = data.terraform_remote_state.layer1.outputs.vpc-id

  ingress {
    description = "TCP FROM ANYWHERE"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-loadbalancer-my-sg"
  }
}


resource "aws_lb" "main-elb" {
  name               = "main-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balanacer-sg.id]
  subnets            = data.terraform_remote_state.layer1.outputs.subnet_id_public

  tags = {
    Environment = "${var.env_code}-loadbalancer-my-sg"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "tf-main-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.layer1.outputs.vpc-id

  health_check {
    enabled             = true
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    port                = "traffic-port"
    path                = "/"
    interval            = "30"
    matcher             = "200"
  }
}


resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}


