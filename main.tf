provider "aws" {
  region = var.aws_region
}
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name        = "${var.name}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.name}-ig"
    Environment = var.environment
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.name}-public-subnet"
    Environment = var.environment
    Zone        = "Public"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  count  = length(var.public_subnet_cidr)

  tags = {
    Name        = "${var.name}-public-route-table"
    Environment = var.environment
    Zone        = "Public"
  }
}

# Public Route
resource "aws_route" "public_ig" {
  count                  = length(var.public_subnet_cidr)
  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route Table Association with Public Subnet
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  route_table_id = element(aws_route_table.public.*.id, count.index)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

# Private Subnet
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id            = aws_vpc.main.id

  tags = {
    Name        = "${var.name}-private-subnet"
    Environment = var.environment
    Zone        = "Private"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.private_subnet_cidr)
  tags = {
    Name        = "${var.name}-private-route-table"
    Environment = var.environment
    Zone        = "Private"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name        = "${var.name}-eip"
    Environment = var.environment
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.private.*.id, 0)
  tags = {
    Name        = "${var.name}-nat"
    Environment = var.environment
  }
}

# Private Route to Internet Via NAT
resource "aws_route" "private_nat" {
  count                  = length(var.private_subnet_cidr)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

# Route Table Association with Private Subnet
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}