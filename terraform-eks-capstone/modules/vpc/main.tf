resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "Prod VPC"
  }
}

# Public Subnet
resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.public_az1
  map_public_ip_on_launch = true
}

# Public Subnet 2
resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.public_az2
  map_public_ip_on_launch = true
}

# Private Subnet 1
resource "aws_subnet" "private_az1" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.private_az1
}

# Private Subnet 2
resource "aws_subnet" "private_az2" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.private_az2
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id
}

# EIP for NAT Gateway
resource "aws_eip" "nat-eip" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.public_az1.id
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
}

