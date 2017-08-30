variable "automate_instance_id" {}

resource "aws_iam_role" "cloudwatch_metrics_role" {
  name = "cloudwatch_metrics_role_${var.automate_instance_id}"
  assume_role_policy = "${file("${path.module}/iam_role.json")}"
}

resource "aws_iam_role_policy" "cloudwatch_metrics_policy" {
  name = "cloudwatch_metrics_policy_${var.automate_instance_id}"
  role = "${aws_iam_role.cloudwatch_metrics_role.id}"
  policy = "${file("${path.module}/iam_policy.json")}"
}

resource "aws_iam_instance_profile" "cloudwatch_metrics_instance_profile" {
  name = "cloudwatch_metrics_instance_profile_${var.automate_instance_id}"
  role = "${aws_iam_role.cloudwatch_metrics_role.name}"
}
