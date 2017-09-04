output "chef_server_sg" {
  value = "${aws_security_group.chef_server.id}"
}

output "automate_sg" {
  value = "${aws_security_group.chef_automate.id}"
}

output "build_nodes_sg" {
  value = "${aws_security_group.build_nodes.id}"
}
