resource "aws_iam_openid_connect_provider" "eks" {
  url = var.eks_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    var.eks_oidc_thumbprint
  ]
}

locals {
  oidc_provider = replace(var.eks_oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "inventory_app_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:ct-aws-dk8s:inventory-app-sa"]
    }
  }
}

resource "aws_iam_role" "inventory_app_irsa_role" {
  name               = "${var.project_name}-${var.environment}-inventory-app-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.inventory_app_assume_role.json
}

resource "aws_iam_role_policy_attachment" "inventory_app_secret_read" {
  role       = aws_iam_role.inventory_app_irsa_role.name
  policy_arn = aws_iam_policy.mysql_secret_read.arn
}
