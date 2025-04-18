# Terraform-Based Scalable AWS Infrastructure

This repository contains Terraform code for deploying a scalable and secure web application infrastructure on AWS. The setup includes a custom VPC, public and private subnets across multiple availability zones, an Application Load Balancer (ALB), EC2 instances behind an Auto Scaling Group, and an RDS database instance — all provisioned as Infrastructure-as-Code.

This project was built as part of the CSYE 6225 Cloud Computing course at Northeastern University but reflects production-grade practices in AWS architecture.

---

## Overview of Architecture

- **Custom VPC** with 5 subnets (3 public, 2 private)
- **Internet Gateway** and **route tables** for public access
- **Application Load Balancer (ALB)** in public subnets
- **Launch Template** for EC2 instances (AMI runs a Go-based web app)
- **Auto Scaling Group (ASG)** to scale instances based on CPU utilization
- **RDS Database** (MySQL or PostgreSQL) deployed in private subnets
- **Security Groups** with strict access rules between ALB, EC2, and RDS
- **User Data Script** to set up application environment and start the service
- **CloudWatch Alarms** to scale in/out based on CPU thresholds

---

## Getting Started

### Prerequisites

- Terraform (`v1.4+`)
- AWS CLI
- Access to AWS Academy Lab account (do **not** use personal AWS account)
- Ubuntu-based EC2 instance for provisioning

---

### Setup Instructions

terraform-scalable-aws-infrastructure/
├── main.tf            # Main configuration
├── variables.tf       # Variable definitions
├── outputs.tf         # Output values
├── terraform.tfvars   # Sensitive inputs (excluded from repo)
├── user_data.sh       # EC2 bootstrapping script
├── README.md
