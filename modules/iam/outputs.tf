output "profile_id" {
  value = "${aws_iam_instance_profile.cloudwatch_metrics_instance_profile.id}"
}
