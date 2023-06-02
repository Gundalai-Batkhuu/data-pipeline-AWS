output "name" {
  value = aws_sfn_state_machine.dpp_state_machine.name
  description = "The name of the state machine"
}

output "arn" {
  value = aws_sfn_state_machine.dpp_state_machine.arn
  description = "The ARN of the state machine"
}

