resource "aws_iam_role" "ecsInstanceRole" {
  name = "ecsInstanceRole"
  assume_role_policy =  file("policies/ecs-instance-role.json")
  
  tags = {
    Name = "ecs_iam"
  }
}

resource "aws_iam_role_policy" "amazonEC2ContainerServiceforEC2Role" {
  name   = "ecs_instance_role_policy"
  policy = file("policies/ecs-instance-role-policy.json")
  role       = aws_iam_role.ecsInstanceRole.name
  }

  resource "aws_iam_instance_profile" "ecs_ec2" {
  name = "ecs_ec2_prof"
  role = aws_iam_role.ecsInstanceRole.name
}