output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
output "bastion_public_ip" { value = module.ec2.bastion_public_ip }
output "app_private_ip" { value = module.ec2.app_private_ip }
output "alb_dns_name" { value = module.asg.alb_dns_name }
output "db_endpoint" { value = module.rds.db_endpoint }
