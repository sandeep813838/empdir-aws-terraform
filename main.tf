terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket         = "empdir-dev-tfstate-061534656974"
    key            = "empdir/dev/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_key_pair" "existing_key" {
  key_name = "empdir-dev-key"
}

module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = "10.0.0.0/16"
  azs                   = ["ap-south-1a", "ap-south-1b"]
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  my_ip        = var.my_ip
}

resource "aws_s3_bucket" "backups" {
  bucket = "${var.project_name}-${var.environment}-backups-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id
  rule {
    id     = "backup-retention"
    status = "Enabled"
    filter {}
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration { days = 90 }
    noncurrent_version_expiration { noncurrent_days = 30 }
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket                  = aws_s3_bucket.backups.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "iam" {
  source = "./modules/iam"

  project_name         = var.project_name
  environment          = var.environment
  s3_backup_bucket_arn = aws_s3_bucket.backups.arn
}

module "ec2" {
  source = "./modules/ec2"

  project_name               = var.project_name
  environment                = var.environment
  ami_id                     = data.aws_ami.amazon_linux_2023.id
  key_name                   = data.aws_key_pair.existing_key.key_name
  public_subnet_id           = module.vpc.public_subnet_ids[0]
  private_subnet_id          = module.vpc.private_subnet_ids[0]
  bastion_sg_id              = module.security_groups.bastion_sg_id
  app_sg_id                  = module.security_groups.app_sg_id
  app_instance_profile_name  = module.iam.ec2_app_instance_profile_name
  web_instance_profile_name  = module.iam.ec2_web_instance_profile_name
}

module "asg" {
  source = "./modules/asg"

  project_name               = var.project_name
  environment                = var.environment
  ami_id                     = data.aws_ami.amazon_linux_2023.id
  key_name                   = data.aws_key_pair.existing_key.key_name
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  web_sg_id                  = module.security_groups.web_sg_id
  alb_sg_id                  = module.security_groups.alb_sg_id
  web_instance_profile_name  = module.iam.ec2_web_instance_profile_name
  min_size                   = 1
  max_size                   = 2
  desired_capacity           = 2
}

module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id
}