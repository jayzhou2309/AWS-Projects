# VPC Module for Serverless Application
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        "Name" = "Serverless VPC"
    }
}

# Public Subnets
resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# EIP for NAT Gateway
resource "aws_eip" "nat_eip" {
    domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_az1.id
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_route" {
    route_table_id = aws_route_table.private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
}

# Security Group for API Gateway
resource "aws_security_group" "api_gateway_sg" {
    name = "api_gateway_sg"
    description = "Security group for API Gateway"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Security Group for Lambda Functions from API Gateway
resource "aws_security_group" "lambda_sg" {
    name = "lambda_sg"
    description = "Security group for Lambda functions from API Gateway"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.api_gateway_sg.id]
    }
}

# Security Group for RDS Instance
resource "aws_security_group" "rds_sg" {
    name = "rds_sg"
    description = "Security group for RDS instance"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.lambda_sg.id]
    }
}
