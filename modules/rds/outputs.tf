output "db_endpoint" { value = aws_db_instance.main.endpoint }
output "db_instance_id" { value = aws_db_instance.main.id }
output "ssm_password_parameter_name" { value = aws_ssm_parameter.db_password.name }