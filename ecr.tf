resource "aws_ecr_repository" "projectecr" {
  name = "project-ecr"
  tags = {
    Name        = "Project-ecr"
    Environment = "Prod"
  }
}