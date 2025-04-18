provider "aws" {
  region = "us-east-1"
}

# Network Module: Creates VPC, subnets, IGW, route tables
module "vpc_networking" {
  source = "./modules/network"
}

# Security Group Module: Creates security groups for EC2, ALB, and RDS
module "sg_config" {
  source = "./modules/security_groups"
  vpc_id = module.vpc_networking.vpc_id
}

# RDS Module: Deploys MySQL DB in private subnets
module "db_setup" {
  source               = "./modules/rds"
  vpc_id               = module.vpc_networking.vpc_id
  private_subnet_ids   = module.vpc_networking.private_subnet_ids
  db_sg_id             = module.sg_config.rds_security_group_id
  app_sg_id            = module.sg_config.ec2_security_group_id
}

# EC2 Module: Launches app instances in public subnets
module "app_instances" {
  source                = "./modules/ec2"
  subnet_ids            = module.vpc_networking.public_subnet_ids
  ec2_sg_id             = module.sg_config.ec2_security_group_id
  database_host         = module.db_setup.db_instance_address
  database_port         = module.db_setup.db_instance_port
  database_user         = module.db_setup.db_username
  database_pass         = module.db_setup.db_password
  database_name         = module.db_setup.db_name
}

# ALB Module: Creates internet-facing ALB
module "load_balancer" {
  source                = "./modules/alb"
  vpc_id                = module.vpc_networking.vpc_id
  public_subnet_ids     = module.vpc_networking.public_subnet_ids
  alb_sg_id             = module.sg_config.alb_security_group_id
}

# Auto Scaling Group Module: Scales app EC2 instances
module "autoscaler" {
  source               = "./modules/autoscaling"
  subnet_ids           = module.vpc_networking.public_subnet_ids
  target_group_arn     = module.load_balancer.target_group_arn
  launch_template_id   = module.app_instances.launch_template_id
}
