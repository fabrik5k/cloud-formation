# Infraestrutura AWS via CloudFormation

Este repositório contém o template principal `main-completo.yaml` e stacks aninhadas para provisionar uma infraestrutura completa na AWS, incluindo:

- VPC com sub-redes públicas e privadas
- Grupos de segurança (Security Groups)
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG) para instâncias EC2
- Instância de banco de dados RDS MySQL
- Alarmes do CloudWatch para monitoramento

---

## 1. Visão Geral

O objetivo deste projeto é fornecer uma base escalável, resiliente e observável para aplicações web em AWS. Utiliza _nested stacks_ para separar responsabilidades de rede e segurança e concentra os recursos de computação e banco de dados em stacks principais.

## 2. Estrutura de Repositório

```text
├── main-completo.yaml      # Template CloudFormation principal
├── network.yaml            # Stack aninhada: VPC, Subnets e Internet Gateway
├── security.yaml           # Stack aninhada: Security Groups
└── README.md               # Este documento de documentação
```

> Os arquivos `network.yaml` e `security.yaml` devem estar hospedados em um bucket S3 acessível pelo CloudFormation (veja seção _Deployment_).  

## 3. Componentes da Infraestrutura

### 3.1 Nested Stacks
- **NetworkStack** (`network.yaml`):
  - VPC (CIDR 10.0.0.0/16)
  - Subnets públicas e privadas em duas AZs
  - Internet Gateway e rotas públicas

- **SecurityStack** (`security.yaml`):
  - Security Group para servidores web (porta TCP 80)
  - Security Group para RDS (porta TCP 3306)

### 3.2 Application Load Balancer (ALB)
- Público, multi-AZ
- Escuta na porta 80
- Distribui requisições para o Target Group das instâncias EC2

### 3.3 Auto Scaling Group (ASG)
- Baseado em um Launch Template:
  - AMI mapeada por região
  - Tipo de instância configurável por ambiente (dev/test/prod)
  - UserData instala e configura Apache HTTP Server
- Min: 2, Desired: parâmetro `DesiredCapacity`, Max: 4
- Aponta para o Target Group do ALB

### 3.4 Banco de Dados RDS
- MySQL 8.0, classe db.t3.micro, 20 GB
- Implantado em subnets privadas (DBSubnetGroup)
- Multi-AZ habilitado em ambientes de produção
- Credenciais armazenadas em parâmetros com `NoEcho`

### 3.5 CloudWatch Alarms
- **CPUAlarmHigh**:
  - Métrica: `AWS/EC2` – `CPUUtilization`
  - Threshold: 75% por 5 min
- **DBConnAlarmHigh**:
  - Métrica: `AWS/RDS` – `DatabaseConnections`
  - Threshold: 50 conexões por 5 min

## 4. Parâmetros do Template

| Parâmetro           | Descrição                                      | Default | Observações                       |
|---------------------|------------------------------------------------|---------|-----------------------------------|
| `Environment`       | Ambiente de implantação                        | dev     | Valores: `dev`, `test`, `prod`    |
| `KeyName`           | Par de chaves SSH para acesso às instâncias    | —       | Deve existir previamente          |
| `DBMasterUsername`  | Usuário administrador do RDS                   | —       | `NoEcho: true`                    |
| `DBMasterUserPassword` | Senha do usuário administrador do RDS       | —       | `NoEcho: true`                    |
| `DesiredCapacity`   | Número desejado de instâncias no ASG           | 2       | Pode ser ajustado sem editar o template |

## 5. Saídas (Outputs)

| Saída               | Descrição                                 |
|---------------------|-------------------------------------------|
| `LoadBalancerDNS`   | DNS público do ALB                        |
| `ASGName`           | Nome do Auto Scaling Group                |
| `DBEndpointAddress` | Endpoint de conexão do RDS MySQL          |
| `Environment`       | Ambiente escolhido na implantação         |

## 6. Como Implantar

1. **Hospedar stacks aninhadas**
   - Faça upload de `network.yaml` e `security.yaml` em um bucket S3 público ou com _permissions_ apropriadas.

2. **Validar template**
   ```bash
   aws cloudformation validate-template --template-body file://main-completo.yaml
   ```

3. **Criar stack**
   ```bash
   aws cloudformation create-stack \
     --stack-name minha-infra \
     --template-body file://main-completo.yaml \
     --capabilities CAPABILITY_NAMED_IAM \
     --parameters \
         ParameterKey=Environment,ParameterValue=dev \
         ParameterKey=KeyName,ParameterValue=meu-keypair \
         ParameterKey=DBMasterUsername,ParameterValue=admin \
         ParameterKey=DBMasterUserPassword,ParameterValue=senhaSegura123 \
         ParameterKey=DesiredCapacity,ParameterValue=2
   ```

4. **Acompanhar criação**
   ```bash
   aws cloudformation describe-stacks --stack-name minha-infra
   ```

## 7. Próximos Passos e Extensões

- **HTTPS**: adicionar listener HTTPS e ACM para TLS
- **Notificações**: integrar SNS/SQS para receber alertas dos alarms
- **Cache**: incluir ElastiCache Redis/Memcached
- **CI/CD**: automatizar deploy com CodePipeline e CodeDeploy

---

## 8. Perguntas Reflexivas Respondidas

- **Por que é importante que o nome do bucket seja globalmente único?**  
  Porque o namespace do Amazon S3 é compartilhado por todas as contas e regiões. Um nome único evita colisões e garante que o endpoint `https://<bucket>.s3.amazonaws.com` aponte somente para o seu bucket.

- **Qual a função da configuração de versionamento no bucket?**  
  O versionamento mantém múltiplas revisões de cada objeto, permitindo restauração de arquivos excluídos ou sobrescritos acidentalmente e adicionando camada extra de proteção em pipelines IaC.

- **Como você modificaria o template para adicionar uma política de ciclo de vida que exclua objetos após 30 dias?**  
  No recurso `AWS::S3::Bucket`, incluir:
  ```yaml
  LifecycleConfiguration:
    Rules:
      - Id: ExpireAfter30Days
        Status: Enabled
        ExpirationInDays: 30
        Prefix: ""
  ```

- **Quais são as vantagens de usar nested stacks?**  
  Facilita a modularidade, reutilização de código, clareza na manutenção e possibilita atualizações isoladas de partes da infraestrutura.

- **Como os outputs de uma nested stack são referenciados na stack principal?**  
  Utilizando `!GetAtt <NestedStack>.Outputs.<OutputName>` ou, quando exportados, `!ImportValue <ExportName>`.

- **Como você modificaria a estrutura para adicionar mais componentes, como um balanceador de carga ou um banco de dados?**  
  Adicionaria um novo arquivo nested (por exemplo `database.yaml`) com o recurso, faria upload ao S3 e referenciaria na stack principal com um novo `AWS::CloudFormation::Stack`. Em seguida, passaria os parâmetros necessários e consumiria os outputs via `!GetAtt`.

---

© 2025 - Projeto de Infraestrutura AWS via CloudFormation
