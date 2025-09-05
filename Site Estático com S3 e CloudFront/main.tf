# Este modelo cria um bucket S3 para hospedar os arquivos de um site, um CloudFront como CDN (Rede de Entrega de Conteúdo) para acelerar a entrega e um registro Route 53 para apontar um domínio personalizado para o site.
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

# Variáveis para personalizar o domínio
variable "domain_name" {
  description = "Domínio para o site (Ex: 'meusite.com')"
  type        = string
}

# Cria o bucket S3 para o site
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.domain_name
}

# Habilita o hosting de site estático no bucket
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# Política para tornar o bucket público (para hosting de site estático)
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })
}

# Cria uma distribuição CloudFront para o site
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled = true
  origins {
    domain_name = aws_s3_bucket.website_bucket.website_endpoint
    origin_id   = aws_s3_bucket.website_bucket.id
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.website_bucket.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  aliases = [var.domain_name]
}

# Exibe a URL da distribuição do CloudFront
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
