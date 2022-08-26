

resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

   tags = {
    name = "main"
   }
}

resource "aws_subnet" "public0" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/27"
  tags = {
    name = "public"
   }
  }
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    name = "private"
   }
  }
resource "aws_subnet" "private0" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/28"
  tags = {
    name = "private0"
   }
  }
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    name = "public1"
   }
  }

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    name = "main"
   }
}


 resource "aws_nat_gateway" "main0" {
   allocation_id = aws_eip.nat1.id
   subnet_id = aws_subnet.private1.id
   tags = {
    name = "main0"
   }
 }

 resource "aws_nat_gateway" "main1" {
   allocation_id = aws_eip.nat0.id
   subnet_id = aws_subnet.private0.id
   tags = {
    name = "main1"
   }
 }

 resource "aws_eip" "nat0" {
  vpc = true
   
   tags = {
    name = "main"
   }
 }

resource "aws_eip" "nat1" {
  vpc = true
   tags = {
    name = "main"
   }
 }

resource "aws_route_table_association" "public1" {
  subnet_id         = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
  
}

resource "aws_route_table_association" "public" {
  subnet_id         = aws_subnet.public0.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private0" {
  subnet_id         = aws_subnet.private1.id
  route_table_id = aws_route_table.private0.id
  
}

resource "aws_route_table_association" "private1" {
  subnet_id         = aws_subnet.private0.id
  route_table_id = aws_route_table.private1.id
  
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

}

resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main0.id
  }
 tags = {
    name = "private0"
   }

}


resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main1.id
  }
  tags = {
    name = "private"
   }

}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

   ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
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
