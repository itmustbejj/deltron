terraform {
  required_version = ">= 0.9.9"
}

# Automate customization
variable "chef-delivery-enterprise" {
  default = "terraform"
}

variable "chef-server-organization" {
  default = "terraform"
}

resource "random_id" "automate_instance_id" {
  byte_length = 4
}

# VPC networking
variable "aws_region" {
  default = "us-west-2"
}

variable "aws_profile" {
  default = "default"
}

variable "automate_vpc" {
  default = "vpc-fa58989d"
} # jhud-vpc in success-aws

variable "automate_subnet" {
  default = "subnet-63c62b04"
}

# unique identifier for this instance of Chef Automate
variable "aws_build_node_instance_type" {
  default = "t2.medium"
}

variable "automate_server_instance_type" {
  default = "m4.xlarge"
}

variable "es_backend_instance_type" {
  default = "m4.xlarge"
}

variable "aws_ami_user" {
  default = "ec2-user"
}

variable "aws_key_pair_name" { }

variable "aws_key_pair_file" { }

variable "automate_es_recipe" {
  default = "recipe[backend_search_cluster::search_es]"
}

# Tagging
variable "automate_tag" {
  default = "terraform_automate"
}

variable "tag_dept" {
  default = "SCE"
}

variable "tag_contact" {
  default = "irving"
}

variable "tag_test_id" {
  default = "automate_scale_test"
}
variable "s3_json_bucket" {
  default = "jhud-backendless-chef2-chefbucket-10qcdk8zn9z9i"
}

variable "external_es_count" {
  default = 3
}

variable "es_backend_volume_size" {
  default = 100
}

variable "logstash_total_procs" {
  default = 1
}

variable "logstash_heap_size" {
  default = "1g"
}

variable "logstash_bulk_size" {
  default = "256"
}

variable "es_index_shard_count" {
  default = 5
}

variable "es_max_content_length" {
  default = "1gb"
}

variable "logstash_workers" {
  default = 12
}

variable "chef_load_instance_type" {
  default = "m4.xlarge"
}

variable "chef_load_rpm" {
  default = "334"   # 10k nodes splayed at 30 min interval
}

variable "converge_status_json_path" {
  default = "/home/ec2-user/jnj_json/jnj_mostly_original_converge_event.json"
}

variable "ohai_json_path" {
  default = "/home/ec2-user/jnj_json/jnj_ohai.json"
}

variable "compliance_status_json_path" {
  default = "/home/ec2-user/chef-load/sample-data/example-compliance-status.json"
}

variable "chef_load_count" {
  default = 1
}

# Basic AWS info
provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}" // uses ~/.aws/credentials by default
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

module "iam_role" {
  source = "./modules/iam"
  automate_instance_id = "${random_id.automate_instance_id.hex}"
}

module "securitygroups" {
  source = "./modules/securitygroups"
  tag_dept = "${var.tag_dept}"
  tag_contact = "${var.tag_contact}"
  automate_tag = "${var.automate_tag}"
  automate_vpc = "${var.automate_vpc}"
  automate_instance_id = "${random_id.automate_instance_id.hex}"
  iam_profile_id = "${module.iam_role.profile_id}"
}

module "chef_server" {
  source = "./modules/chef_server"
  tag_dept = "${var.tag_dept}"
  tag_contact = "${var.tag_contact}"
  tag_test_id = "${var.tag_test_id}"
  automate_tag = "${var.automate_tag}"
  automate_subnet = "${var.automate_subnet}"
  aws_key_pair_name = "${var.aws_key_pair_name}"
  automate_instance_id = "${random_id.automate_instance_id.hex}"
  ami_id = "${data.aws_ami.amazon_linux.id}"
  security_group_id = "${module.securitygroups.chef_server_sg}"
  iam_profile_id = "${module.iam_role.profile_id}"
  aws_ami_user = "${var.aws_ami_user}"
  aws_key_pair_file = "${var.aws_key_pair_file}"
}

module "es_backends" {
  source ="./modules/automate_es_backends"
  external_es_count = "${var.external_es_count}"
  es_backend_volume_size = "${var.es_backend_volume_size}"
  tag_dept = "${var.tag_dept}"
  tag_contact = "${var.tag_contact}"
  tag_test_id = "${var.tag_test_id}"
  automate_tag = "${var.automate_tag}"
  automate_subnet = "${var.automate_subnet}"
  aws_key_pair_name = "${var.aws_key_pair_name}"
  automate_instance_id = "${random_id.automate_instance_id.hex}"
  es_backend_instance_type = "${var.es_backend_instance_type}"
  aws_region = "${var.aws_region}"
  es_index_shard_count = "${var.es_index_shard_count}"
  es_max_content_length = "${var.es_max_content_length}"
  ami_id = "${data.aws_ami.amazon_linux.id}"
  security_group_id = "${module.securitygroups.automate_sg}"
  iam_profile_id = "${module.iam_role.profile_id}"
  chef_server_fqdn = "${module.chef_server.fqdn}"
  delivery_pem = "${module.chef_server.delivery_pem}"
  aws_ami_user = "${var.aws_ami_user}"
  aws_key_pair_file = "${var.aws_key_pair_file}"
}

module "automate" {
  source = "./modules/automate"
  logstash_total_procs = 1
  logstash_heap_size = "1g"
  logstash_bulk_size = "256"
  logstash_workers = 12
  tag_dept = "${var.tag_dept}"
  tag_contact = "${var.tag_contact}"
  tag_test_id = "${var.tag_test_id}"
  automate_tag = "${var.automate_tag}"
  automate_subnet = "${var.automate_subnet}"
  aws_key_pair_name = "${var.aws_key_pair_name}"
  automate_instance_id = "${random_id.automate_instance_id.hex}"
  ami_id = "${data.aws_ami.amazon_linux.id}"
  security_group_id = "${module.securitygroups.automate_sg}"
  iam_profile_id = "${module.iam_role.profile_id}"
  automate_server_instance_type = "${var.automate_server_instance_type}"
  delivery_pem = "${module.chef_server.delivery_pem}"
  ami_id = "${data.aws_ami.amazon_linux.id}"
  chef_server_fqdn = "${module.chef_server.fqdn}"
  es_peers = "${module.es_backends.es_peers}"
  aws_ami_user = "${var.aws_ami_user}"
  aws_key_pair_file = "${var.aws_key_pair_file}"
}

module "chef_load" {
  source = "./modules/chef_load"
  tag_dept = "${var.tag_dept}"
  tag_contact = "${var.tag_contact}"
  tag_test_id = "${var.tag_test_id}"
  automate_tag = "${var.automate_tag}"
  automate_subnet = "${var.automate_subnet}"
  aws_key_pair_name = "${var.aws_key_pair_name}"
  automate_instance_id = "${random_id.automate_instance_id.hex}"
  ami_id = "${data.aws_ami.amazon_linux.id}"
  s3_json_bucket = "${var.s3_json_bucket}"
  security_group_id = "${module.securitygroups.automate_sg}"
  iam_profile_id = "${module.iam_role.profile_id}"
  chef_load_instance_type = "${var.chef_load_instance_type}"
  delivery_pem = "${module.chef_server.delivery_pem}"
  chef_server_fqdn = "${module.chef_server.fqdn}"
  automate_fqdn = "${module.automate.fqdn}"
  aws_ami_user = "${var.aws_ami_user}"
  aws_key_pair_file = "${var.aws_key_pair_file}"
}
