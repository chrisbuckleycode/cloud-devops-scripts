resource "aws_iam_role" "cluster_role_eks" {
  name = "EKSClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_role_attach_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster_role_eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "cluster_eks" {
  name     = "cluster_eks"
  role_arn = aws_iam_role.cluster_role_eks.arn

  vpc_config {
    subnet_ids = [aws_subnet.private_subnet_01_eks.id, aws_subnet.private_subnet_02_eks.id]
    endpoint_private_access = true
    endpoint_public_access = true
    public_access_cidrs = ["0.0.0.0/0"]  # change later
    security_group_ids = [aws_security_group.sg_cluster_comm_nodes_eks.id]
  }

  kubernetes_network_config {
    ip_family = "ipv4"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_attach_AmazonEKSClusterPolicy,
    #aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}
