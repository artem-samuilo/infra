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