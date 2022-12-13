output "lb-sg" {
  value = aws_security_group.load_balanacer-sg.id
}

output "target-arn" {
  value = aws_lb_target_group.main.arn
}

