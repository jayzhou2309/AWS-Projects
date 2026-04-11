provider "aws" {
  region = var.region
  profile = var.profile
}

# VPC Resources
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "autoscaling-vpc"
  }
}

resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "autoscaling-public-az1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "autoscaling-public-az2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "autoscaling-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "autoscaling-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_az1" {
  subnet_id = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Compute Resources
resource "aws_alb" "alb" {
  vpc_id = aws_vpc.main.id
  subnets = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
  security_groups = [ aws_security_group.alb_sg.id ]
}

resource "aws_alb_target_group" "tg" {
  name = "autoscaling-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  health_check {
    path = "/"
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
}

resource "aws_launch_template" "lt" {
  name = "autoscaling-lt"
  image_id = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
  user_data = <<-EOF
#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
EOF
}

resource "aws_autoscaling_group" "asg" {
  name = "autoscaling-asg"
  max_size = 3
  min_size = 1
  desired_capacity = 2
  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_alb_target_group.tg.arn]
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
}

resource "aws_autoscaling_policy" "scale_down" {
  name = "scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name = "cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300
  statistic = "Average"
  threshold = 70
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name = "cpu-low-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300
  statistic = "Average"
  threshold = 30
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
