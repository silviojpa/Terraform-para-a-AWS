# Este é um exemplo de como provisionar um cluster Amazon EKS com um grupo de nós gerenciados. Ele é simplificado, mas demonstra os recursos essenciais para iniciar um cluster.
# Define o provider da AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC e Subnets necessárias para o EKS
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "eks_public" {
  count = 2
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index + 1}.0/24"
  availability_zone = "us-east-1${count.index == 0 ? "a" : "b"}"
  tags = {
    Name = "eks-subnet-${count.index}"
  }
}

# Cria um IAM Role para o cluster EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Atribui a política de cluster do EKS
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Cria o Cluster EKS
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = aws_subnet.eks_public[*].id
  }
}

# Cria um IAM Role para os nós (workers)
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Atribui políticas de nó do EKS
resource "aws_iam_role_policy_attachment" "eks_node_policy_1" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_node_policy_2" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Cria um Node Group gerenciado pelo EKS
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks_public[*].id
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t2.medium"]
}

# Exibe o endpoint do cluster
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
