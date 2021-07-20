data "aws_subnet_ids" "private" {
   vpc_id = module.vpc_prod.vpc_id
   filter {
    name   = "tag:Name"
    values = ["aws_subnet_private*"]
  }
}

resource "aws_autoscaling_group" "ecs-cluster" {
  name                 = "ec2_es2_auto_scaling_group"
  min_size             = 1
  max_size             = 4
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ecs_ec2_launch_conf.name
  vpc_zone_identifier  = data.aws_subnet_ids.private.ids
#  target_group_arns    = [aws_lb_target_group.frontend.arn]

  tag {
    key                 = "Name"
    value               = "ECS_Instance"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "ecs_ec2_launch_conf" {
  name          = "ECS_Cluster"
  image_id      = "ami-0b440d17bfb7989dc"
  instance_type = "t3.nano"
  security_groups             = [aws_security_group.asg_ecs_ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs_ec2.name
  associate_public_ip_address = false
  key_name = "workpc"
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

resource "aws_autoscaling_policy" "agents-scale-up" {
    name = "agents-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster.name}"
}

resource "aws_autoscaling_policy" "agents-scale-down" {
    name = "agents-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster.name}"
}

resource "aws_cloudwatch_metric_alarm" "memory-high" {
    alarm_name = "mem-util-high-agents"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "AWS/EC2"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "Memory utilization >80%"
    alarm_actions = [
        "${aws_autoscaling_policy.agents-scale-up.arn}",
        "${aws_appautoscaling_policy.up.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.ecs-cluster.name
    }
}

resource "aws_cloudwatch_metric_alarm" "memory-low" {
    alarm_name = "mem-util-low-agents"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "AWS/EC2"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "Memory utilization is normal"
    alarm_actions = [
        "${aws_autoscaling_policy.agents-scale-down.arn}",
        "${aws_appautoscaling_policy.down.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.ecs-cluster.name
    }
}

resource "aws_security_group" "asg_ecs_ec2" {
  name                      = "asg_ecs_ec2"
  vpc_id                    = module.vpc_prod.vpc_id

  ingress {
    from_port               = 0
    to_port                 = 65535
    protocol                = "tcp"
    security_groups         = [aws_security_group.load-balancer.id]
  }


  ingress {
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    security_groups         = [aws_security_group.bastion.id]
  }


  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
}

resource "aws_appautoscaling_target" "ecs_app_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_project.name}/${aws_ecs_service.ecs_project_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "up" {
    name = "${aws_ecs_service.ecs_project_service.name}_scale_up"
    service_namespace  = "ecs"
    resource_id        = aws_appautoscaling_target.ecs_app_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_app_target.scalable_dimension   
    step_scaling_policy_configuration {
        adjustment_type = "ChangeInCapacity"
        cooldown = 60
        metric_aggregation_type = "Maximum"
        step_adjustment {
            metric_interval_lower_bound = 0
            scaling_adjustment = 2
        }
    }
    depends_on = [aws_appautoscaling_target.ecs_app_target]
}

resource "aws_appautoscaling_policy" "down" {
    name = "${aws_ecs_service.ecs_project_service.name}_scale_down"
    service_namespace = "ecs"
    resource_id        = aws_appautoscaling_target.ecs_app_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_app_target.scalable_dimension   
    step_scaling_policy_configuration {
        adjustment_type = "ChangeInCapacity"
        cooldown = 60
        metric_aggregation_type = "Maximum"
        step_adjustment {
            metric_interval_lower_bound = 0
            scaling_adjustment = -2
        }
    }
    depends_on = [aws_appautoscaling_target.ecs_app_target]
}