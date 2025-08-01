variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
  default     = "oz-key-pair"
}

variable "private_key_path" {
  description = "Path to the private key on your local machine"
  type        = string
  default     = "~/.ssh/oz-key-pair.pem"
}

