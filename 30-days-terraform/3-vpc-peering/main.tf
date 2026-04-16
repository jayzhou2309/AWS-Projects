provider "aws" {
    region = var.region
    profile = var.profile
}

# VPC 1
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
    tags = {
        Name = "VPC1"
    }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id
    tags = {
        Name = "RT1"
    }
}

resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
    tags = {
        Name = "Subnet1"
    }
}

# VPC 2
resource "aws_vpc" "vpc2" {
  cidr_block = "10.1.0.0/16"
    tags = {
        Name = "VPC2"
    }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc2.id
    tags = {
        Name = "RT2"
    }
}

resource "aws_route_table_association" "rta2" {
 subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.vpc2.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
    tags = {
        Name = "Subnet2"
    }
}

# VPC Peering
resource "aws_vpc_peering_connection" "peer" {
  vpc_id = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true
    tags = {
        Name = "VPCPeering"
    }
}

# Routes for VPC Peering
resource "aws_route" "route1" {
  route_table_id = aws_route_table.rt1.id
  destination_cidr_block = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route2" {
  route_table_id = aws_route_table.rt2.id
  destination_cidr_block = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# EC2 Instances
resource "aws_key_pair" "keypair" {
  key_name = "my_key_pair"
  public_key = file(pathexpand("~/Downloads/AWS/peering-key-pair.pub"))
}

resource "aws_instance" "instance1" {
  ami = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet1.id
  availability_zone = "us-east-1a"
  vpc_security_group_ids = [ aws_security_group.sg1.id ]
  key_name = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
    tags = {
        Name = "Instance1"
    }
}

resource "aws_instance" "instance2" {
  ami = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet2.id
  availability_zone = "us-east-1a"
  vpc_security_group_ids = [ aws_security_group.sg2.id ]
  key_name = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
    tags = {
        Name = "Instance2"
    }
}

resource "aws_security_group" "sg1" {
  name = "sg1"
  description = "Allow SSH"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]  # Replace with your public IP
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg2" {
  name = "sg2"
  description = "Allow SSH"
  vpc_id = aws_vpc.vpc2.id

  # Allow SSH from your machine
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${local.my_ip}/32", "10.0.0.0/16"]  # Replace with your public IP
  }

  # Allow SSH from VPC1 (for peering)
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

