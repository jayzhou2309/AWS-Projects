resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id

  ingress = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami = ""
  instance_type = "t3.micro"
  subnet_id = var.subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.web_sg.id]

}

resource "aws_lb" "web_alb" {
  load_balancer_type = "application"
    subnets = var.subnet_ids
}