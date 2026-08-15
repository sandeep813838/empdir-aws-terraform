data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_app_role" {
  name               = "${var.project_name}-${var.environment}-ec2-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "s3_backup_access" {
  statement {
    sid       = "BackupBucketAccess"
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
    resources = [var.s3_backup_bucket_arn, "${var.s3_backup_bucket_arn}/*"]
  }
  statement {
    sid       = "SSMParameterRead"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"]
  }
}

resource "aws_iam_policy" "s3_backup_policy" {
  name   = "${var.project_name}-${var.environment}-s3-backup-policy"
  policy = data.aws_iam_policy_document.s3_backup_access.json
}

resource "aws_iam_role_policy_attachment" "app_s3_backup" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}

resource "aws_iam_role_policy_attachment" "app_ssm_core" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_cloudwatch_agent" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "${var.project_name}-${var.environment}-ec2-app-role"
  role = aws_iam_role.ec2_app_role.name
}

resource "aws_iam_role" "ec2_web_role" {
  name               = "${var.project_name}-${var.environment}-ec2-web-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "web_ssm_core" {
  role       = aws_iam_role.ec2_web_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "web_cloudwatch_agent" {
  role       = aws_iam_role.ec2_web_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_web_profile" {
  name = "${var.project_name}-${var.environment}-ec2-web-role"
  role = aws_iam_role.ec2_web_role.name
}