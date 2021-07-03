data "aws_subnet_ids" "public" {
   vpc_id = aws_vpc.main.id
   tags = {
       Name = "aws_subnet_public"
   }
}

resource "aws_autoscaling_group" "ecs-cluster" {
  name                 = "ec2_es2_auto_scaling_group"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ecs_ec2_launch_conf.name
  vpc_zone_identifier  = data.aws_subnet_ids.public.ids
  target_group_arns    = [aws_lb_target_group.frontend.arn]
}

resource "aws_launch_configuration" "ecs_ec2_launch_conf" {
  name          = "ECS_Cluster"
  image_id      = "ami-0b440d17bfb7989dc"
  instance_type = "t3.nano"
  security_groups             = [aws_security_group.asg_ecs_ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs_ec2.name
  associate_public_ip_address = true
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    delete_on_termination = true
  }
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs_project.name} >> /etc/ecs/ecs.config;
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
EOF
 lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "asg_ecs_ec2" {
  name                      = "asg_ecs_ec2"
  vpc_id                    = "${aws_vpc.main.id}"

  ingress {
    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port               = 8080
    to_port                 = 8080
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }


  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
}

resource "aws_appautoscaling_target" "ecs_app_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_project.name}/${aws_ecs_service.ecs_project_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "frontend-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}