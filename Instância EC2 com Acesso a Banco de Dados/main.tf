# Este modelo cria uma VPC (nuvem privada virtual), uma sub-rede pública, um grupo de segurança para controlar o tráfego e uma instância EC2 que pode ser usada para se conectar a um banco de dados (que estaria em uma sub-rede privada).
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

# Cria a VPC (Virtual Private Cloud)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Cria uma Subnet pública dentro da VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Cria um Security Group para permitir acesso SSH e de banco de dados
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Permite acesso SSH e DB"
  vpc_id      = aws_vpc.main.id

  # Regra de entrada para SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acesso de qualquer IP (Mude para seu IP em produção)
  }

  # Regra de entrada para acesso a banco de dados (Exemplo: PostgreSQL)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Acesso apenas da VPC (Ajuste conforme a localização do seu DB)
  }

  # Permite todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Cria a Instância EC2
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Exemplo: AMI do Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "app-server"
  }
}

# Exibe o endereço IP público da instância
output "public_ip" {
  value = aws_instance.app_server.public_ip
}
