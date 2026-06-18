terraform {
  backend "s3" {
    bucket         = "ctk8s-terraform-state-326095712541"
    key            = "terraform/backend/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
