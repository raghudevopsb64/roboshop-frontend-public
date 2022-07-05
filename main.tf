resource "aws_lb" "public" {
  name               = "roboshop-public-${var.ENV}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.PUBLIC_SUBNETS

  tags = {
    Environment = "roboshop-public-${var.ENV}"
  }
}

resource "aws_lb_target_group" "frontend-alb-ips" {
  name        = "frontend-alb-ips-${var.ENV}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.DEFAULT_VPC_ID
  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    path                = "/health"
    port                = 80
  }
}

resource "aws_lb_target_group_attachment" "add-ip" {
  count             = length(data.dns_a_record_set.frontend.addrs)
  target_group_arn  = aws_lb_target_group.frontend-alb-ips.arn
  target_id         = element(data.dns_a_record_set.frontend.addrs, count.index)
  availability_zone = "all"
  port              = 80
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend-alb-ips.arn
  }
}

resource "aws_security_group" "alb" {
  name        = "allow_alb_public_${var.ENV}"
  description = "allow_alb_public_${var.ENV}"
  vpc_id      = var.DEFAULT_VPC_ID

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_alb_public_${var.ENV}"
  }
}

resource "aws_route53_record" "public-alb" {
  zone_id = "Z03439621SCOB6CXGIDUM"
  name    = "roboshop.devopsb64.online"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.public.dns_name]
}


