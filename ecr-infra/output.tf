output "fluent_bit_registry_url" {
  value = aws_ecr_repository.fluentbit_repository.repository_url
}