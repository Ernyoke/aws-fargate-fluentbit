output "alb_dns" {
  description = "ALB FQDN"
  value       = aws_alb.fluent_bit_alb.dns_name
}