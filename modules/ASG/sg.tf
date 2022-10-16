resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Https from load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lb-sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-my-sg"
  }
}



