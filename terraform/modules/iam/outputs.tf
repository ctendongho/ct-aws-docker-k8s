output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "eks_cluster_role_name" {
  value = aws_iam_role.eks_cluster_role.name
}

output "eks_node_role_name" {
  value = aws_iam_role.eks_node_role.name
}

output "mysql_secret_read_policy_arn" {
  value = aws_iam_policy.mysql_secret_read.arn
}

output "inventory_app_irsa_role_arn" {
  value = aws_iam_role.inventory_app_irsa_role.arn
}
