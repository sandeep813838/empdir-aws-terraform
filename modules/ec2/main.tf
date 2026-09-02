resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = var.web_instance_profile_name

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = "t3.small" # was "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  iam_instance_profile   = var.app_instance_profile_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app"
  }
}

resource "aws_ebs_volume" "app_data" {
  availability_zone = aws_instance.app.availability_zone
  size              = 5
  type              = "gp3"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-data"
  }
}

resource "aws_volume_attachment" "app_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.app_data.id
  instance_id = aws_instance.app.id
}