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

resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow ssh inbound traffic"
  vpc_id      = data.terraform_remote_state.layer1.outputs.vpc-id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.sg_cidr]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.layer1.outputs.vpc_cidr]
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

resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.layer1.outputs.vpc-id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.layer1.outputs.vpc_cidr]
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

resource "aws_instance" "public" {
  ami                    = data.aws_ami.linux-image.id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.layer1.outputs.subnet_id_public[0]
  vpc_security_group_ids = [aws_security_group.public.id]
  key_name               = "ansible"

  user_data = file("user-data.sh")

  associate_public_ip_address = true

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.linux-image.id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.layer1.outputs.subnet_id_private[0]
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = "ansible"

  tags = {
    Name = "${var.env_code}-private"
  }
}
