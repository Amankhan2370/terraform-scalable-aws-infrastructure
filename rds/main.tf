# -------------------------------
# RDS Subnet Group for Private Subnets
# -------------------------------
resource "aws_db_subnet_group" "db_subnet_group_main" {
  name       = "db-subnet-group"
  subnet_ids = var.backend_subnets
}

# -------------------------------
# Custom Parameter Group
# -------------------------------
resource "aws_db_parameter_group" "postgres_params" {
  name   = "custom-postgres-pg"
  family = "postgres17"

  parameter {
    name         = "rds.force_ssl"
    value        = "0"
    apply_method = "immediate"
  }
}

# -------------------------------
# RDS Instance (PostgreSQL)
# -------------------------------
resource "aws_db_instance" "app_database" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t3.micro"

  db_name                = "appdb"
  username               = "appuser"
  password               = "appsecurepass"  # Replace before final deployment
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group_main.name
  vpc_security_group_ids = [var.db_sg]
  parameter_group_name   = aws_db_parameter_group.postgres_params.name

  publicly_accessible    = false
  skip_final_snapshot    = true
}

# -------------------------------
# Input Variables
# -------------------------------
variable "vpc_id" {
  type = string
}

variable "backend_subnets" {
  type = list(string)
}

variable "db_sg" {
  type = string
}

variable "ec2_sg" {
  type = string
}

# -------------------------------
# Output Values
# -------------------------------
output "db_instance_address" {
  value = aws_db_instance.app_database.address
}

output "db_instance_port" {
  value = aws_db_instance.app_database.port
}

output "db_username" {
  value = aws_db_instance.app_database.username
}

output "db_password" {
  value     = aws_db_instance.app_database.password
  sensitive = true
}

output "db_name" {
  value = aws_db_instance.app_database.db_name
}
