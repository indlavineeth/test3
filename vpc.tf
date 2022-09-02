# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "stage-main"
  }
}

#internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "stage-main"
  }
}

resource "aws_subnet" "Public" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.pub_cidr,count.index)
  map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "stage-public${count.index+1}"
  }
}

#route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "stage_public"
  }
}

#route table association
resource "aws_route_table_association" "a" {
  count = length(aws_subnet.Public[*].id)
  subnet_id      = element (aws_subnet.Public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}