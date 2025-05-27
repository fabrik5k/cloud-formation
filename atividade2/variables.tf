# variables.tf

variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Par de chaves SSH para as instâncias EC2"
  type        = string
}

variable "db_username" {
  description = "Usuário administrador do RDS"
  type        = string
}

variable "db_password" {
  description = "Senha do usuário administrador do RDS"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos"
  type        = map(string)
  default = {
    Project     = "TerraformProject"
    ManagedBy   = "Terraform"
  }
}

