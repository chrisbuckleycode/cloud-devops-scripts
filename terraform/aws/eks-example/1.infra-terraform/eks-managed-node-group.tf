resource "aws_iam_role" "node_role_eks" {
  name = "EKSNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_role_attach_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_role_eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_role_attach_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_role_eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_role_attach_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_role_eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "node_group_eks" {
  cluster_name    = aws_eks_cluster.cluster_eks.name
  node_group_name = "node_group_eks"
  node_role_arn   = aws_iam_role.node_role_eks.arn
  subnet_ids      = [aws_subnet.private_subnet_01_eks.id, aws_subnet.private_subnet_02_eks.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_role_attach_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_role_attach_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_role_attach_AmazonEC2ContainerRegistryReadOnly,
  ]
}
