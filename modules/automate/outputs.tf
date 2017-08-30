output "fqdn" {
  value = "${aws_instance.chef_automate.public_dns}"
}
