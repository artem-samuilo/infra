
terraform {
  backend "s3" {
    bucket = "tfstatebucket-internal-project"
    key    = "terraform_state.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}
