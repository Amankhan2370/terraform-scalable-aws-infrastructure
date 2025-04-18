# ------------------------------------
# Security Group for Load Balancer
# ------------------------------------
resource "aws_security_group" "sg_alb" {
  name        = "sg-alb"
  description = "Allows inbound HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------
# Security Group for EC2 Instances
# ------------------------------------
resource "aws_security_group" "sg_ec2" {
  name        = "sg-ec2"
  description = "Allows traffic to app from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------
# Security Group for RDS Database
# ------------------------------------
resource "aws_security_group" "sg_db" {
  name        = "sg-db"
  description = "Allows Postgres access from EC2 only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ec2.id]
  }

  # No
