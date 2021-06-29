
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "state-bucket/terraform_state.tfstate"
    region = var.region
  }
}

provider "aws" {
    region = var.region
}
