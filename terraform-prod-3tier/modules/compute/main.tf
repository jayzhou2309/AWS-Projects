# Launch Template for EC2 Instances
resource "aws_launch_template" "app_lt" {
    name_prefix = "app-template"
    image_id = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
    instance_type = "t3.micro"

    vpc_security_group_ids = [aws_security_group.ec2_sg.id]

    user_data = base64encode(file("${path.module}/../ec2-user-data.sh"))
}

# Auto Scaling Group for EC2 Instances
resource "aws_autoscaling_group" "app_asg" {
    desired_capacity = 2
    max_size = 4
    min_size = 2

    vpc_zone_identifier = [aws_subnet.private_app_az1.id, aws_subnet.private_app_az2.id]
    launch_template {
        id = aws_launch_template.app_lt.id
        version = "$Latest"
    }

    target_group_arns = [aws_lb_target_group.app_tg.arn]
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
    name = "app-alb"
    internal = false
    load_balancer_type = "application"

    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
}

#Target Group for ALB
resource "aws_lb_target_group" "app_tg" {

    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
}

# Listener for ALB
resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.app_alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
    }
}