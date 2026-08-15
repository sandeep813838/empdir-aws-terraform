# Employee Directory — AWS Infrastructure (Terraform)

Modular Terraform configuration provisioning a 3-tier AWS architecture:
VPC, IAM, Security Groups, EC2 (bastion + app), Auto Scaling Group + ALB, and RDS MySQL.

## Structure
- `modules/vpc` — VPC, subnets, IGW, NAT Gateway, route tables
- `modules/security-groups` — Security groups with SG-to-SG referencing (no hardcoded CIDRs)
- `modules/iam` — EC2 IAM roles and least-privilege policies
- `modules/ec2` — Bastion host and application instance
- `modules/asg` — Launch Template, ALB, Target Group, Auto Scaling Group
- `modules/rds` — RDS MySQL with auto-generated password stored in SSM Parameter Store

## Backend
Remote state in S3 with DynamoDB state locking.

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values
2. `terraform init`
3. `terraform plan`
4. `terraform apply`

## Notes
- `skip_final_snapshot = true` on RDS is a lab-only convenience; set `false` in production
- Free-tier AWS accounts require `backup_retention_period <= 1` on RDS
