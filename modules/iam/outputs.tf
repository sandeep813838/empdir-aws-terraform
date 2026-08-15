output "ec2_app_role_arn" { value = aws_iam_role.ec2_app_role.arn }
output "ec2_app_role_name" { value = aws_iam_role.ec2_app_role.name }
output "ec2_app_instance_profile_name" { value = aws_iam_instance_profile.ec2_app_profile.name }
output "ec2_app_instance_profile_arn" { value = aws_iam_instance_profile.ec2_app_profile.arn }

output "ec2_web_role_arn" { value = aws_iam_role.ec2_web_role.arn }
output "ec2_web_role_name" { value = aws_iam_role.ec2_web_role.name }
output "ec2_web_instance_profile_name" { value = aws_iam_instance_profile.ec2_web_profile.name }
output "ec2_web_instance_profile_arn" { value = aws_iam_instance_profile.ec2_web_profile.arn }
