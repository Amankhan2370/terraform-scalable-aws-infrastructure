# -----------------------------------
# Launch Template for EC2 Instances
# -----------------------------------
resource "aws_launch_template" "app_template" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-03a6c16a66bbe0a7a"  # Update if needed
  instance_type = "t3.micro"
  key_name      = "vockey"
  vpc_security_group_ids = [var.instance_sg]

  user_data = base64encode(<<-EOT
    #!/bin/bash
    sudo mkdir /usr/bin/project_env
    sudo touch /usr/bin/project_env/.env
    echo "DB_HOST=${var.database_host}" >> /usr/bin/project_env/.env
    echo "DB_PORT=${var.database_port}" >> /usr/bin/project_env/.env
    echo "DB_USERNAME=${var.database_user}" >> /usr/bin/project_env/.env
    echo "DB_PASSWORD=${var.database_pass}" >> /usr/bin/project_env/.env
    echo "DB_NAME=${var.database_name}" >> /usr/bin/project_env/.env
    sudo chmod 600 /usr/bin/project_env/.env
    sudo chown csye6225:csye6225 /usr/bin/project_env/.env
    sudo systemctl start webapp.service
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
    }
  }
}

# -----------------------------------
# Input Variables
# -----------------------------------
variable "subnet_ids" {
  type = list(string)
}

variable "instance_sg" {
  type = string
}

variable "database_host" {
  type = string
}

variable "database_port" {
  type = number
}

variable "database_user" {
  type = string
}

variable "database_pass" {
  type     = string
  sensitive = true
}

variable "database_name" {
  type = string
}

# -----------------------------------
# Output
# -----------------------------------
output "launch_template_id" {
  value = aws_launch_template.app_template.id
}
