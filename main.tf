locals {
  public_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
}

resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "main"
  }
}

resource "aws_subnet" "private" {
  count = length(local.private_cidr)

  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = local.private_cidr[count.index]

  tags = {
    name = "private${count.index}"
  }
}

resource "aws_subnet" "public" {
  count = length(local.public_cidr)

  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = local.public_cidr[count.index]

  tags = {
    name = "public${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    name = "main"
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(local.private_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.private[count.index].id

  tags = {
    name = "main${count.index}"
  }
}

resource "aws_eip" "nat" {
  count = length(local.private_cidr)

  vpc = true

  tags = {
    name = "nats${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(local.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "private" {
  count = length(local.private_cidr)

  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    name = "private${count.index}"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my-sg"
  }
}
