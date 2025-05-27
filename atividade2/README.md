# Terraform AWS: Desafio Final

Este projeto demonstra a extensão de uma infraestrutura básica em AWS usando **Terraform**, atendendo aos seguintes requisitos do desafio:

1. **Auto Scaling Group (ASG)** para gerenciar automaticamente a quantidade de instâncias EC2  
2. **Banco de dados RDS** MySQL implantado em subnets privadas  
3. **CloudWatch Alarms** para monitorar a utilização de CPU nas instâncias e conexões no RDS  
4. **Pipeline CI/CD** via GitHub Actions para automação de **terraform plan** e **terraform apply**

---

## 📋 Requisitos Atividade

- 📈 **Escalabilidade**: Auto Scaling Group para as EC2, entre 2 e 4 instâncias, com Launch Template.  
- 🗄️ **Persistência Segura**: RDS MySQL (db.t3.micro, 20 GB), não publicamente acessível e em subnets privadas.  
- 🔔 **Monitoramento**: CloudWatch Metric Alarms:  
  - CPUUtilization > 75 % (EC2) por 5 min  
  - DatabaseConnections > 50 (RDS) por 5 min  
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
3. Para pipelines automáticas, basta push em **main** no GitHub.

---

**Resultado**: infraestrutura AWS escalável, segura, monitorada e com deploy automatizado.

---

## 8. 🧠 Perguntas Reflexivas Respondidas

### 📑 Seção 1 – Bucket S3

| Pergunta                                                                          | Resposta                                                                                                                                           |
|-----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| **Qual a diferença entre `terraform plan` e `terraform apply`?**                  | `terraform plan` gera um _execution plan_ mostrando **o que** será criado/alterado/destruído sem fazer mudanças; `terraform apply` **executa** o plano e realiza as alterações na nuvem. |
| **Por que é importante usar versionamento em um bucket S3?**                      | O versionamento cria uma nova versão a cada alteração ou exclusão de objeto, permitindo **recuperação de dados, auditoria e proteção contra deleção acidental**.                         |
| **Como adicionar uma política de ciclo de vida que exclua objetos após 30 dias?** | Em `aws_s3_bucket`, acrescente:  
```hcl
lifecycle_rule {
  id      = "expire-after-30d"
  enabled = true
  expiration {
    days = 30
  }
}
```                                                                                                                                            |

### 🌐 Seção 2 – VPC / AZ / NAT

| Pergunta                                                                                          | Resposta                                                                                                                                                                                   |
|---------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Por que usamos `data "aws_availability_zones"` em vez de hardcoded AZs?**                      | Garante **portabilidade** entre regiões, sempre obtendo AZs válidas e disponíveis, evitando erros se uma AZ for desativada ou inexistente.                                                |
| **Qual a função do NAT Gateway e por que ele é necessário?**                                      | Permite que instâncias em **subnets privadas** iniciem conexões outbound para a Internet (atualizações, downloads) **sem exposição pública de IP**.                                        |
| **Como usar variáveis para os blocos CIDR?**                                                     | Declarar em `variables.tf`:  
```hcl
variable "public_subnet_cidrs" {
  type = list(string)
}
```  
e referenciar `var.public_subnet_cidrs[count.index]` nas subnets em vez de valores fixos.                                         |

### 🖼️ Seção 3 – AMI / Load Balancer / ASG

| Pergunta                                                                          | Resposta                                                                                                                                                      |
|-----------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Por que usamos `data "aws_ami"` em vez de especificar diretamente um ID de AMI?** | Seleciona **automaticamente** a AMI mais recente (p.ex. Amazon Linux 2) e mantém o código válido em qualquer região sem manutenção manual.                         |
| **Qual a vantagem de usar um Load Balancer na frente das instâncias EC2?**        | Distribui tráfego, oferece **alta disponibilidade**, health checks, escalabilidade e ponto único para TLS/HTTPS.                                               |
| **Como modificar o código para usar Auto Scaling Group em vez de instâncias individuais?** | Substituir recursos `aws_instance` por:  
1. `aws_launch_template` (definição da instância)  
2. `aws_autoscaling_group` (min/desired/max & subnets)  
3. Opcional: `aws_lb_target_group` + `aws_lb` para integrar. *(Já implementado em `asg.tf`)* |

### 🧩 Seção 4 – Módulos / Variáveis / Tags

| Pergunta                                           | Resposta                                                                                                                               |
|----------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| **Quais são as vantagens de usar módulos no Terraform?** | Reuso, organização, **baixa repetição de código**, versionamento separado e testes isolados dos componentes.                             |
| **Como o uso de variáveis torna o código mais flexível?** | Permite alterar parâmetros (tipo de instância, CIDRs, região) **sem editar** os arquivos principais, viabilizando múltiplos ambientes com o mesmo código-base. |
| **Por que é importante usar a função `merge` para tags?**   | Combina tags fixas do projeto com tags dinâmicas/locais, evitando sobrescrita e garantindo **consistência** em todos os recursos.       |

### 📦 Seção 5 – Estado Remoto & Workspaces

| Pergunta                                                              | Resposta                                                                                                                                                                                      |
|-----------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Quais são as vantagens de usar um backend remoto para o estado do Terraform?** | Estado fica **centralizado, versionado, bloqueado por DynamoDB** (evita corridas) e disponível para pipelines CI/CD.                                                                            |
| **Como os workspaces ajudam a gerenciar múltiplos ambientes?**        | Cada workspace possui um **state file isolado**; assim, `dev`, `staging`, `prod` compartilham código mas têm estados independentes, reduzindo risco de interferência.                         |
| **Quais são os desafios de gerenciar múltiplos ambientes com Terraform?** | Manter variáveis sensíveis específicas, lidar com **drift** entre ambientes, controlar permissões, e complexidade de promover mudanças de forma auditável entre workspaces. |

---

© 2025 - Projeto Terraform AWS · Desafio Final
