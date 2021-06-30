resource "aws_ecs_cluster" "ecs_project" {
  name = "ecs_project"
  tags = {
    Name        = "project-ecs"
  }
}
/*

resource "aws_cloudwatch_log_group" "log-group" {
  name = "docker-logs"

  tags = {
    Application = Project
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "project-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "apache2-container",
      "image": "apache2:latest",
      "entryPoint": ["/usr/sbin/apache2ctl", "-DFOREGROUND"],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "eu-central-1",
          "awslogs-stream-prefix": "apache-logs"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name        = "apache-ecs-td"
  }
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "apache-ecs-service"
  cluster              = aws_ecs_cluster.ecs-ecs_project.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.listener]
}
*/