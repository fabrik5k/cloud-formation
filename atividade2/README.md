# Terraform AWS: Desafio Final

Este projeto demonstra a extensão de uma infraestrutura básica em AWS usando **Terraform**, atendendo aos seguintes requisitos do desafio:

1. **Auto Scaling Group (ASG)** para gerenciar automaticamente a quantidade de instâncias EC2
2. **Banco de dados RDS** MySQL implantado em subnets privadas
3. **CloudWatch Alarms** para monitorar a utilização de CPU nas instâncias e conexões no RDS
4. **Pipeline CI/CD** via GitHub Actions para automação de **terraform plan** e **terraform apply**

---

## 📋 Requisitos Atividade

- 📈 **Escalabilidade**: Auto Scaling Group para as EC2, entre 2 e 4 instâncias, com Launch Template.
- 🗄️ **Persistência Segura**: RDS MySQL (db.t3.micro, 20 GB), não publicamente acessível e em subnets privadas.
- 🔔 **Monitoramento**: CloudWatch Metric Alarms:
  - CPUUtilization > 75% (EC2) por 5 minutos
  - DatabaseConnections > 50 (RDS) por 5 minutos
- 🤖 **Automação de Deploy**: GitHub Actions executando `terraform plan` em PRs e `terraform apply` em pushes para **main**.

---

## 🗂️ Estrutura do Projeto

```text
terraform-projeto/
├── providers.tf           # Provider AWS e backend remoto em S3/DynamoDB
├── variables.tf           # Declaração de variáveis reutilizáveis e tags
├── outputs.tf             # Outputs: ALB DNS, ASG name, RDS endpoint, environment
│
├── modules/
│   └── vpc/               # Módulo de VPC, subnets públicas/privadas, IGW
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── asg.tf                 # Launch Template + Auto Scaling Group
├── rds.tf                 # DB Subnet Group, SG e instância RDS MySQL
├── monitoring.tf          # CloudWatch Alarms para EC2 e RDS
└── .github/
    └── workflows/
        └── terraform.yml  # Workflow GitHub Actions para CI/CD Terraform
```

---

## ⚙️ Componentes Principais

- **Auto Scaling Group** (`asg.tf`): configura instâncias EC2 com Launch Template, HTTP Server e scaling automático.
- **RDS MySQL** (`rds.tf`): isolado em subnets privadas, SG restrito, sem acesso público.
- **CloudWatch Alarms** (`monitoring.tf`): configura alarmes para CPU e conexões simultâneas.
- **GitHub Actions** (`.github/workflows/terraform.yml`): garante qualidade e automatiza deploy em `main`.

---

## 🚀 Como Usar

1. Preencha `terraform.tfvars` ou defina variáveis de CI/CD: `aws_region`, `environment`, `key_name`, `db_username`, `db_password`.
2. Execute localmente:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
3. Para pipelines automáticas, basta push em `main` no GitHub.

---

**Resultado**: infraestrutura AWS escalável, segura, monitorada e com deploy automatizado.

© 2025 - Projeto Terraform AWS - Desafio Final

