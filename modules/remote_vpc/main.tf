/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- moudles/connect_peer/main.tf ---

# List of AZs available in the AWS Region
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_info.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${var.identifier}"
  }
}

# Connect VPC IGW
resource "aws_internet_gateway" "connect_vpc_igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "connect-vpc/internet-gateway"
  }
}

# Default Security Group
# Ensuring that the default SG restricts all traffic (no ingress and egress rule). It is also not used in any resource
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id
}

# SUBNETS
# Private Subnets - either to create instances or VPC endpoints
resource "aws_subnet" "vpc_public_subnets" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = [for i in range(11, 14) : cidrsubnet(var.vpc_info.cidr_block, 8, i)][count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-public-subnet-${var.identifier}-${count.index + 1}"
  }
}

# Private Subnets - either to create instances or VPC endpoints
resource "aws_subnet" "vpc_private_subnets" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = [for i in range(101, 104) : cidrsubnet(var.vpc_info.cidr_block, 8, i)][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet-${var.identifier}-${count.index + 1}"
  }
}


# ROUTE TABLES

# Private Subnet Route Table
resource "aws_route_table" "vpc_private_subnet_route_table" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-private-subnet-rt-${var.identifier}-${count.index + 1}"
  }
}

resource "aws_route_table_association" "vpc_private_subnet_route_table_assoc" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.vpc_private_subnets[count.index].id
  route_table_id = aws_route_table.vpc_private_subnet_route_table[count.index].id
}

resource "aws_route_table" "vpc_public_subnet_route_table" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-public-subnet-rt-${var.identifier}-${count.index + 1}"
  }
}

resource "aws_route_table_association" "vpc_public_subnet_route_table_assoc" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.vpc_public_subnets[count.index].id
  route_table_id = aws_route_table.vpc_public_subnet_route_table[count.index].id
}

# Route entries
resource "aws_route" "public_internet_gateway" {
  count                  = var.vpc_info.number_azs
  route_table_id         = aws_route_table.vpc_public_subnet_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.connect_vpc_igw.id

  timeouts {
    create = "5m"
  }
}