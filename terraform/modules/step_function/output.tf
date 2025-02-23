output "step_func_arn" {
  value = aws_sfn_state_machine.sfn_state_machine.arn
}

# output "step_func_cloudwatch_alarm_ExecutionThrottled" {
#   value = aws_cloudwatch_metric_alarm.create_alarms_ExecutionThrottled.arn
# }

# output "step_func_cloudwatch_alarm_ExecutionsAborted" {
#   value = aws_cloudwatch_metric_alarm.create_alarms_ExecutionsAborted.arn
# }

# output "step_func_cloudwatch_alarm_ExecutionsFailed" {
#   value = aws_cloudwatch_metric_alarm.create_alarms_ExecutionsFailed.arn
# }

# output "step_func_cloudwatch_alarm_ExecutionsTimedOut" {
#   value = aws_cloudwatch_metric_alarm.create_alarms_ExecutionsTimedOut.arn
# }
