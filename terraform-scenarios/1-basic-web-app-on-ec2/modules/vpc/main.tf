# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}
# Subnets
resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}
resource "aws_subnet" "private_az1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "private_az2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}
# IGW, EIP, NAT
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  vpc_id = aws_vpc.main_vpc.id
  subnet_id = aws_subnet.public_az1
}
# Routes
resource "aws_route" "public_rt" {
  
}

resource "aws_route" "private_rt" {
  
}

# SG