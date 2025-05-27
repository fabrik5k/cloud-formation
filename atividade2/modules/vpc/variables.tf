# modules/vpc/variables.tf

variable "environment" {
  description = "Dev, test ou prod"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
}

variable "tags" {
  description = "Tags para todos os recursos"
  type        = map(string)
  default     = {}
}

