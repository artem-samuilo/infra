variable "region" {
  type        = string
  default     = "eu-central-1"
}

variable default_az {
  type        = string
  default     = "eu-central-1a"
}


variable "vpc_cidr" {
  default     = "[10.0.0.0/20]"
}
