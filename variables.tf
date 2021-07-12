variable "aws_region" {
  type        = string
  default     = "eu-central-1"
}


variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/20"
}

variable availability_zones {
  type        = list(string)
  default     = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}