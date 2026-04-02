resource "aws_db_subnet_group" "db_subnet" {
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "db" {
  engine = "mysql"
  instance_class = "db.t3.micro"
  allocated_storage = 20

  username = "admin"
  password = "password"

  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
}