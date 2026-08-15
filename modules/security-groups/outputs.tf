output "bastion_sg_id" { value = aws_security_group.bastion.id }
output "alb_sg_id" { value = aws_security_group.alb.id }
output "web_sg_id" { value = aws_security_group.web.id }
output "app_sg_id" { value = aws_security_group.app.id }
output "rds_sg_id" { value = aws_security_group.rds.id }
output "efs_sg_id" { value = aws_security_group.efs.id }