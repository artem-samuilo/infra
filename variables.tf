variable "region" {
  type        = string
  default     = "eu-central-1"
}


variable "vpc_cidr" {
  type        = list(string) 
  default     = "[10.0.0.0/20]"
}

variable availability_zones {
  type        = list(string)
  default     = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}

variable private_subnets {
  type        = list(string)
  default     = [
    "10.1.0.0/24",
    "10.2.0.0/24"
  ]
}

variable public_subnets {
  type        = list(string)
  default     = [
    "10.3.0.0/24",
    "10.4.0.0/24"
  ]
}