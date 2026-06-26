variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "admin_cidr" {
  type = string
}

variable "mysql_secret_arn" {
  type = string
}

variable "eks_oidc_issuer_url" {
  type = string
}

variable "eks_oidc_thumbprint" {
  type = string
}
