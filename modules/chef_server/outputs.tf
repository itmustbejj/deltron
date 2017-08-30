output "fqdn" {
  value = "${aws_instance.chef_server.public_dns}"
}
