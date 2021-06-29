resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "aws_subnet_private_1" {
    cidr_block              = "10.0.0.0/24"
    vpc_id                  = "${aws_vpc.main.id}"
    map_public_ip_on_launch = "false"
    availability_zone       = var.default_az
    tags {
        Name            = "aws_subnet_private_1"
    }
}

resource "aws_subnet" "aws_subnet_private_2" {
    cidr_block              = "10.1.0.0/24"
    vpc_id                  = "${aws_vpc.main.id}"
    map_public_ip_on_launch = "false"
    availability_zone       = var.default_az
    tags {
        Name            = "aws_subnet_private_2"
    }
}

resource "aws_subnet" "aws_subnet_public_1" {
    cidr_block              = "10.2.0.0/24"
    vpc_id                  = "${aws_vpc.main.id}"
    map_public_ip_on_launch = "true"
    availability_zone       = var.default_az
    tags {
        Name            = "aws_subnet_public_1"
    }
}

resource "aws_subnet" "aws_subnet_public_1" {
    cidr_block              = "10.3.0.0/24"
    vpc_id                  = "${aws_vpc.main.id}"
    map_public_ip_on_launch = "true"
    availability_zone       = var.default_az
    tags {
        Name            = "aws_subnet_public_2"
    }