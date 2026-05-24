variable "aws_region" {
  default = "eu-north-1"
}

variable "project_name" {
  default = "demo-project"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS for eu-north-1"
  default     = "ami-0c1ac8a41498c1a9c"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "your_ip" {
  description = "Your laptop IP for SSH access - find it at whatismyip.com"
  type        = string
}
