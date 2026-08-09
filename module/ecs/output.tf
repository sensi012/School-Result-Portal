output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}