resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "public" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.${count.index}.0/24"
}

resource "aws_subnet" "private" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.${count.index + 2}.0/24  "
}