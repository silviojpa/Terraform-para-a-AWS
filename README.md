# Exemplos de Projetos com Terraform na AWS

Este repositório contém exemplos práticos de como usar o **Terraform** para provisionar infraestrutura na **Amazon Web Services (AWS)**. Os exemplos estão organizados em pastas, cada uma contendo um projeto diferente para que você possa entender e aplicar os conceitos de infraestrutura como código (IaC).

## O que é Terraform?

**Terraform** é uma ferramenta de código aberto para provisionar e gerenciar infraestrutura. Com ele, você pode definir a sua infraestrutura em arquivos de configuração (escritos em HCL - HashiCorp Configuration Language), permitindo que você crie, altere e versiona os recursos de forma segura e eficiente.

## Estrutura do Repositório

* **`Cluster Kubernetes com EKS`**: Demonstra como criar um cluster **Amazon EKS** com um grupo de nós gerenciados, a base para rodar suas aplicações em containers.
* **`Instância EC2 com Acesso a Banco de Dados`**: Mostra a criação de uma **VPC**, **subnets** e uma **instância EC2** configurada para se conectar a um banco de dados, ideal para ambientes de desenvolvimento ou pequenas aplicações.
* **`Serviço Serverless com Lambda e API Gateway`**: Um exemplo prático de arquitetura **serverless**, provisionando uma função **AWS Lambda** e expondo-a via **API Gateway**, tudo com Terraform.
* **`Site Estático com S3 e CloudFront`**: Guia para hospedar um site estático no **S3** e usar o **CloudFront** para entregá-lo globalmente com baixa latência, um caso de uso comum para sites e portfólios.

## Dicas para Começar

Para usar qualquer um dos exemplos, siga estes passos:

1.  **Pré-requisitos**:
    * Tenha o **Terraform** instalado em sua máquina.
    * Configure suas credenciais da **AWS**. A maneira mais simples é usando o AWS CLI.

2.  **Passos para Execução**:
    * Navegue até a pasta do exemplo que você deseja usar (ex: `cd "Serviço Serverless com Lambda e API Gateway"`).
    * **Inicie o projeto**: `terraform init` (Este comando baixa os plugins necessários para se comunicar com a AWS).
    * **Planeje as alterações**: `terraform plan` (Este comando mostra um resumo detalhado dos recursos que serão criados, alterados ou destruídos. **Sempre execute esta etapa para evitar surpresas!**).
    * **Aplique as alterações**: `terraform apply` (Este comando cria os recursos na sua conta da AWS conforme o plano. Digite `yes` para confirmar a criação).

3.  **Para Destruir a Infraestrutura**:
    * Quando não precisar mais dos recursos, você pode destruí-los para evitar custos: `terraform destroy`.

## Contribuições

Sinta-se à vontade para explorar os exemplos, sugerir melhorias ou adicionar novos projetos. Qualquer contribuição é bem-vinda!

---
