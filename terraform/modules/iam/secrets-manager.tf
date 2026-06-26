resource "aws_iam_policy" "mysql_secret_read" {
  name        = "${var.project_name}-${var.environment}-mysql-secret-read"
  description = "Allow EKS application to read MySQL credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.mysql_secret_arn
      }
    ]
  })
}
