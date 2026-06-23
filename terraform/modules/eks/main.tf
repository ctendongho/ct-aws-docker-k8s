resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-eks"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.eks_nodes_sg_id]
  }

  tags = {
    Name    = "${var.project_name}-eks"
    Project = var.project_name
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-ng"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.small"]

  tags = {
    Name    = "${var.project_name}-ng"
    Project = var.project_name
  }
}

