variable "project_name" {
  type = string
}

variable "environment" {
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
