variable "aws_region" {
  default = "us-east-1"
}

variable "cpu" {
  default = 512
}

variable "memory" {
  default = 1024
}

variable "img" {
  default = "public.ecr.aws/nginx/nginx:1.21-perl"
}

variable "container_port" {
  default = 80
}