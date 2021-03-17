provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Private"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public"
  }

}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "GW for Main"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "Public_RT"
  }
}
resource "aws_route_table" "privare_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "Private_RT"
  }
}
resource "aws_route" "int" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "r" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "sg1" {
  name        = "SSH"
  description = "This will allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Rule for SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow SSH"
  }

}
resource "aws_instance" "TF_int" {
  ami                    = "ami-038f1ca1bd58a5790"
  vpc_security_group_ids = [aws_security_group.sg1.id]
  subnet_id              = aws_subnet.public.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.mykey.key_name
}
resource "aws_key_pair" "mykey" {
  key_name   = "my-ec2-key"
  public_key = file("tf_ec2_key.pub")
}
####