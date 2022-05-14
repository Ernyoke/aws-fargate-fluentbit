resource "aws_ecr_repository" "fluentbit_repository" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"
}