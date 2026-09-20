resource "aws_lb" "lb" {
  name               = "lb"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public.id,
    aws_subnet.public2.id
  ]

  security_groups = [aws_security_group.alb.id]
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}


resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}


resource "aws_lb_target_group" "web" {
  name     = "web"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "traffic-port"
  }
}


resource "aws_lb_target_group_attachment" "web_ec2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.ec2.id
  port             = 8000
}


resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]
}