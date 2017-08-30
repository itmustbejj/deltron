output "es_peers" {
  value = "${aws_instance.es_backend.*.public_dns}"
}
