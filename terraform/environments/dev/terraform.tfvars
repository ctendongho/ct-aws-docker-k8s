aws_region   = "us-east-2"
project_name = "ct-aws-docker-k8s"
environment  = "dev"

vpc_cidr = "10.20.0.0/16"

public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24",
  "10.20.3.0/24"
]

private_subnet_cidrs = [
  "10.20.11.0/24",
  "10.20.12.0/24",
  "10.20.13.0/24"
]

availability_zones = [
  "us-east-2a",
  "us-east-2b",
  "us-east-2c"
]

db_username = "sqladmin"
db_password = "January*spring22"

admin_cidr = "172.31.43.79/32"

mysql_secret_arn = "arn:aws:secretsmanager:us-east-2:326095712541:secret:ct-aws-dk8s/mysql-FOP7vy"

eks_oidc_issuer_url = "https://oidc.eks.us-east-2.amazonaws.com/id/03DA3679EA931801BC4E323477965608"
eks_oidc_thumbprint = "E8098C708E7E2088EE8B1C903DD954D9A49A6CDC"
