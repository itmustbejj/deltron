variable "tag_dept" {}
variable "tag_contact" {}
variable "tag_test_id" {}
variable "automate_subnet"  {}
variable "automate_tag" {}
variable "automate_instance_id" {}
variable "aws_key_pair_name" {}
variable "ami_id" {}
variable "security_group_id" {}
variable "iam_profile_id" {}
variable "delivery_pem" {}
variable "chef_server_fqdn" {}
variable "automate_fqdn" {}
variable "s3_json_bucket" {}
variable "aws_ami_user" {}
variable "aws_key_pair_file" {}

data "template_file" "chef_load_conf" {
  template = "${file("${path.module}/chef_load.conf.tpl")}"

  vars {
    chef_server_fqdn     = "${var.chef_server_fqdn}"
    automate_server_fqdn = "${var.automate_fqdn}"
    rpm = "${var.chef_load_rpm}"
    ohai_json_path = "${var.ohai_json_path}"
    compliance_status_json_path = "${var.compliance_status_json_path}"
    converge_status_json_path = "${var.converge_status_json_path}"
  }
}

resource "aws_instance" "chef_load" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${var.ami_id}"
  iam_instance_profile        = "${var.iam_profile_id}"
  instance_type               = "${var.chef_load_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${var.automate_subnet}"
  vpc_security_group_ids      = ["${var.security_group_id}"]
  associate_public_ip_address = true
  ebs_optimized               = true
  count                  = "${var.chef_load_count}"

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"

    #iops        = 1000
  }

  tags {
    Name      = "${format("${var.automate_tag}_${var.automate_instance_id}_chef_load_%02d", count.index + 1)}"
    X-Dept    = "${var.tag_dept}"
    X-Contact = "${var.tag_contact}"
    TestId    = "${var.tag_test_id}"
  }

  # Set hostname in separate connection.
  # Transient hostname doesn't set correctly in time otherwise.
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.automate_fqdn}",
      "sudo mkdir /etc/chef/",
    ]
  }

  provisioner "file" {
    content     = "${var.delivery_pem}"
    destination = "/home/ec2-user/delivery-validator.pem"
  }

  provisioner "file" {
    content = "${data.template_file.chef_load_conf.rendered}"
    destination = "/home/ec2-user/chef_load.conf"
  }

  provisioner "file" {
    source = "./files/chef_load.service"
    destination = "/tmp/chef_load.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/chef_load.service /etc/systemd/system/chef_load.service",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git nscd -y",
      "cd && git clone https://github.com/jeremiahsnapp/chef-load.git",
      "wget https://github.com/chef/chef-load/releases/download/v1.0.0/chef-load_1.0.0_Linux_64bit -O chef-load-1.0.0",
      "chmod +x chef-load-1.0.0",
      "chmod 600 delivery-validator.pem",
      "knife ssl fetch https://${var.chef_server_fqdn}",
      "aws s3 cp s3://${var.s3_json_bucket}/jnj_json.tar /home/ec2-user/jnj_json.tar",
      "tar -xzf /home/ec2-user/jnj_json.tar",
      "sudo systemctl start chef_load",
    ]
  }
}

output "chef_load_server" {
  value = "${aws_instance.chef_load.public_dns}"
}
