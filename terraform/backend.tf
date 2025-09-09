terraform {
  backend "s3" {
    bucket         = "multicloud-terraform-state-1757424435"
    key            = "multicloud/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
