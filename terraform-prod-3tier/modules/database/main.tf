# Private RDS Database Subnet Group
resource "aws_db_subnet_group" "db_subnets" {
  subnet_ids = [
    aws_subnet.private_db_az1.id, 
    aws_subnet.private_db_az2.id 
  ]
}

# RDS Database Instance
resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  engine = "mysql"
  instance_class = "db.t3.micro"

  db_name = "appdb"
  username = "admin"
  password = "password123"

  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
}
