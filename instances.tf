data "aws_ami" "ubuntu" {
  most_recent               = true

  filter {
    name                    = "name"
    values                  = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name                    = "virtualization-type"
    values                  = ["hvm"]
  }

  owners                    = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion_host" {
  count                     = 1
  ami                       = data.aws_ami.ubuntu.id
  instance_type             = "t3.micro"
  subnet_id                 = element(module.vpc_prod.public_subnets_ids, 0)
  vpc_security_group_ids    = ["${aws_security_group.bastion.id}"]
  key_name = "workpc"
  root_block_device {
      volume_size = "20"
    }

  tags = {
    Name = "Bastion Host"
  }
}


resource "aws_security_group" "bastion" {
  name                      = "SG-Bastion"
  vpc_id                    = module.vpc_prod.vpc_id

  ingress {
    from_port               = 22
    to_port                 = 22
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