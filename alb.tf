data "aws_subnet_ids" "public" {
   vpc_id = module.vpc_prod.vpc_id
   filter {
    name   = "tag:Name"
    values = ["aws_subnet_public*"]
  }
}

resource "aws_lb" "ecs-alb" {
  name               = "ecs-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = data.aws_subnet_ids.public.ids
}

resource "aws_lb_target_group" "frontend" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_prod.vpc_id
  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}


resource "aws_lb_listener" "frontend_ecs-alb-http-listener" {
  load_balancer_arn = aws_lb.ecs-alb.id
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_lb_target_group.frontend]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_security_group" "load-balancer" {
  name        = "load_balancer_security_group"
  description = "Controls access to the ALB"
  vpc_id      = module.vpc_prod.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}