# Create VPC
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = var.vpc_name
        env  = "Elbeanstalk"
        vpc  = var.vpc_name
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.vpc_name}-IGW"
        env  = "Elbeanstalk"   
        vpc  = var.vpc_name
    }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet" {
    count             = length(var.public_subnet_cidr_blocks)
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = var.public_subnet_cidr_blocks[count.index]
    availability_zone = element(var.availability_zones, count.index)
    tags = {
        Name = "${var.vpc_name}_Public Subnet ${count.index + 1}"
        env  = "Elbeanstalk"
        vpc  = var.vpc_name
    }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet" {
    count             = length(var.private_subnet_cidr_blocks)
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = var.private_subnet_cidr_blocks[count.index]
    availability_zone = element(var.availability_zones, count.index)
    tags = {
        Name = "${var.vpc_name}_Private Subnet ${count.index + 1}"
        env  = "Elbeanstalk"
        vpc  = var.vpc_name
    }
}

# Create Route Tables
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "Public Route Table"
        env  = "Elbeanstalk"
        vpc  = var.vpc_name
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "Private Route Table"
        env  = "Elbeanstalk"
        vpc  = var.vpc_name
    }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
    count          = length(var.public_subnet_cidr_blocks)
    subnet_id      = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
    count          = length(var.private_subnet_cidr_blocks)
    subnet_id      = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private_route_table.id
}

# Create Route for Public Subnets
resource "aws_route" "public_route" {
    route_table_id         = aws_route_table.public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.IGW.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
    domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet[0].id
    tags = {
        Name = "${var.vpc_name}-NAT-Gateway"
        env  = "Elbeanstalk"
        vpc  = var.vpc_name
    }
}

# Create Route for Private Subnets
resource "aws_route" "private_route" {
    route_table_id         = aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

