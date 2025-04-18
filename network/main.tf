# -----------------------------
# VPC Creation
# -----------------------------
resource "aws_vpc" "project_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "project-vpc"
  }
}

# -----------------------------
# Public Subnets (Across 3 AZs)
# -----------------------------
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "public-subnet-c"
  }
}

# -----------------------------
# Private Subnets (Backend)
# -----------------------------
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.10.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.10.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-b"
  }
}

# -----------------------------
# Internet Gateway + Public Route Table
# -----------------------------
resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.project_vpc.id
}

resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }

  tags = {
    Name = "public-routes"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "assoc_public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_routes.id
}

resource "aws_route_table_association" "assoc_public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_routes.id
}

resource "aws_route_table_association" "assoc_public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_routes.id
}

# -----------------------------
# Private Route Table
# -----------------------------
resource "aws_route_table" "private_routes" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "private-routes"
  }
}

resource "aws_route_table_association" "assoc_private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_routes.id
}

resource "aws_route_table_association" "assoc_private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_routes.id
}

# -----------------------------
# Outputs
# -----------------------------
output "vpc_id" {
  value = aws_vpc.project_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id,
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]
}
