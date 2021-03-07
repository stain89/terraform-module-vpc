variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS Region to build the VPC in.  Only one region is supported right now."
}
variable "name" {
  type        = string
  default     = "test"
  description = "Name of product to which resource belongs to"
}

variable "environment" {
  type        = string
  default     = "test"
  description = "Environment resource belong to. Ex Dev/Test/Prod"
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/24"
  description = "Range of IP address that we use in this VPC"
}

variable "public_subnet_cidr" {
  type        = list(string)
  default     = ["192.168.0.0/26", "192.168.0.64/26"]
  description = "CIDR block for public subnet"
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["192.168.0.128/26", "192.168.0.192/26"]
  description = "CIDR block for private subnet"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
  description = "Availability Zones for VPC"
}
