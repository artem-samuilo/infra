resource "aws_vpc" "main" {
    cidr_block               = var.vpc_cidr
    tags = {
     Name = "main"
  }
}

resource "aws_internet_gateway" "aws-igw" {
    vpc_id                   = aws_vpc.main.id
    tags = {
     Name = "main-igw"
  }

}

resource "aws_subnet" "aws_subnet_private" {
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = element(var.private_subnets, count.index)
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = "false"
    count                   = length(var.private_subnets)
    tags = {
     Name = "aws_subnet_private"
    }
}

resource "aws_subnet" "aws_subnet_public" {
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = element(var.public_subnets, count.index)
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = "true"
    count                   = length(var.public_subnets)
    tags = {
     Name = "aws_subnet_public"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
     Name = "main-routing-table-public"
  }
}

resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
    count                  = length(var.public_subnets)
    subnet_id              = element(aws_subnet.aws_subnet_public.*.id, count.index)
    route_table_id         = aws_route_table.public.id
}

resource "aws_eip" "aws_eip" {
    vpc                    = true
    depends_on             = [aws_internet_gateway.aws-igw]
}

resource "aws_nat_gateway" "nat_gw" {
    connectivity_type      = "public"
    allocation_id          = "${aws_eip.aws_eip.id}"
    subnet_id              = element(aws_subnet.aws_subnet_public.*.id, 0)
    depends_on             = [aws_internet_gateway.aws-igw]
    tags = {
     Name = "NAT_GW"
  }
}

resource "aws_route_table" "private" {
    vpc_id                 = aws_vpc.main.id
    tags = {
     Name = "main-routing-table-private"
  }
}

resource "aws_route" "private" {
    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private" {
    count                  = length(var.private_subnets)
    subnet_id              = element(aws_subnet.aws_subnet_private.*.id, count.index)
    route_table_id         = aws_route_table.private.id
}