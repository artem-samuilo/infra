resource "aws_ecs_cluster" "ecs_project" {
  name = "ecs_project"
  tags = {
    Name        = "ecs_project"
  }
}

resource "aws_cloudwatch_log_group" "ecs_project-log-group" {
  name = "ecs_project-logs"

  tags = {
    Application = "Project"
  }
}

resource "aws_cloudwatch_log_stream" "ecs_project-log-stream" {
  name           = "ecs_project-log-stream"
  log_group_name = aws_cloudwatch_log_group.ecs_project-log-group.name
}

resource "aws_ecs_task_definition" "ecs_project-task-def" {
  family = "ecs_project-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "tomcat",
      "image": "tomcat:latest",
      "essential": true,
      "memory": 128,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.ecs_project-log-group.id}",
          "awslogs-region": "eu-central-1",
          "awslogs-stream-prefix": "${aws_cloudwatch_log_stream.ecs_project-log-stream.name}"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 0
        }
      ],
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["EC2"]
  tags = {
    Name        = "tomcat-ecs-td"
  }
}

resource "aws_ecs_service" "ecs_project_service" {
  name            = "ecs_project_service"
  cluster         = aws_ecs_cluster.ecs_project.id
  task_definition = aws_ecs_task_definition.ecs_project-task-def.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = "tomcat"
    container_port   = 8080
  }
}
