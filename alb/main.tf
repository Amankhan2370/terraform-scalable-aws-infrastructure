resource "aws_lb" "alb_main" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = var.public_subnets
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb_main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "target-group-app"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/healthz"
    protocol = "HTTP"
  }
}

# -----------------------
# Input Variables
# -----------------------

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "lb_sg_id" {
  type = string
}

# -----------------------
# Output Values
# -----------------------

output "target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}
