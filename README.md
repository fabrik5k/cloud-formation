# Projeto DevOps AWS com Terraform e CloudFormation

Este repositório contém dois projetos distintos de infraestrutura como código, cada um utilizando uma ferramenta diferente:

- 🔶 **Terraform** – Criação e gerenciamento de infraestrutura em AWS com automação via GitHub Actions
- 🔷 **CloudFormation** – Provisão de recursos AWS com stacks aninhadas (nested stacks)

Ambos os projetos atendem a desafios práticos que envolvem escalabilidade, banco de dados, monitoramento e boas práticas de automação.

---

## 🔶 Projeto Terraform

### ✅ Requisitos do Desafio

- [x] Auto Scaling Group com Launch Template para instâncias EC2
- [x] Banco de dados RDS MySQL em subnets privadas
- [x] CloudWatch Alarms para CPU (EC2) e conexões simultâneas (RDS)
- [x] Pipeline CI/CD usando GitHub Actions

### 📁 Estrutura

- `providers.tf`, `variables.tf`, `outputs.tf`: configuração base
- `asg.tf`: escalabilidade com Auto Scaling Group
- `rds.tf`: banco de dados privado com SG dedicado
- `monitoring.tf`: alarmes de monitoramento
- `.github/workflows/terraform.yml`: CI/CD para Terraform
- `modules/vpc/`: VPC e subnets reutilizáveis

### 📌 Execução

```bash
terraform init
terraform apply
```

GitHub Actions aplica automaticamente na branch `main`.

---

## 🔷 Projeto CloudFormation

### ✅ Requisitos do Desafio

- [x] Application Load Balancer (ALB) diante das instâncias EC2
- [x] Auto Scaling Group com Launch Template
- [x] Banco de dados RDS em subnets privadas
- [x] Alarmes CloudWatch para EC2 e RDS

### 📁 Estrutura

- `main-completo.yaml`: template principal da stack
- `network.yaml`: nested stack de rede (VPC, subnets, roteamento)
- `security.yaml`: nested stack de segurança (SGs)

### 📌 Execução

1. Faça upload de `network.yaml` e `security.yaml` em um bucket S3 acessível.
2. Execute:

```bash
aws cloudformation create-stack \
  --stack-name projeto-cloudformation \
  --template-body file://main-completo.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters file://params.json
```

3. Monitore via Console AWS ou CLI.

---

## 📘 Comparativo entre Projetos

| Recurso                     | Terraform                  | CloudFormation             |
|----------------------------|----------------------------|----------------------------|
| Definição modular          | Sim (módulos)              | Sim (nested stacks)        |
| Automação (CI/CD)          | Sim (GitHub Actions)       | Manual ou via CodePipeline |
| Facilidade de leitura      | Alta (sintaxe declarativa) | Moderada                   |
| Manutenção                 | Flexível (tfstate)         | Controlada via StackSet    |
| Portabilidade              | Alta                       | Restrita à AWS             |

---

## 🧠 Conclusão

Este repositório demonstra como duas ferramentas distintas podem ser usadas para alcançar os mesmos objetivos de provisionamento e automação em nuvem, cada uma com suas vantagens e particularidades.

> A abordagem com **Terraform** se destaca pela integração CI/CD e reusabilidade de código.
> A abordagem com **CloudFormation** é ideal quando se deseja usar exclusivamente recursos nativos AWS e facilitar o uso com StackSets.

---

© 2025 - Projeto de Infraestrutura como Código com Terraform e CloudFormation

