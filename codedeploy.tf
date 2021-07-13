/*resource "aws_iam_role" "aws_code_deploy" {
  name = "aws_code_deploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "aws_code_deploy_policy" {
  name   = "aws_code_deploy_policy"
  policy = file("policies/ecs-code-deploy-role.json")
  role       = aws_iam_role.aws_code_deploy.name
  }

resource "aws_codedeploy_app" "web-app" {
  compute_platform = "ECS"
  name             = "web-app"
}

resource "aws_codedeploy_deployment_group" "web-app-dg" {
  app_name               = aws_codedeploy_app.web-app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "web-app-dg"
  service_role_arn       = aws_iam_role.aws_code_deploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action            = "TERMINATE"
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs_project.name
    service_name = aws_ecs_service.ecs_project_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.frontend_ecs-alb-http-listener.arn]
      }

      target_group {
        name = aws_lb_target_group.frontend-blue.name
      }

      target_group {
        name = aws_lb_target_group.frontend-green.name
      }
    }
}
}
*/