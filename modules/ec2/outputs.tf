output "bastion_public_ip" { value = aws_instance.bastion.public_ip }
output "bastion_id" { value = aws_instance.bastion.id }
output "app_private_ip" { value = aws_instance.app.private_ip }
output "app_id" { value = aws_instance.app.id }