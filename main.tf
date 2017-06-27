terraform {
  required_version = "0.9.9"
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

variable "automate_subnet" {}

data "aws_subnet_ids" "automate" {
  vpc_id = "${var.automate_vpc}"
}

# unique identifier for this instance of Chef Automate
variable "aws_build_node_instance_type" {
  default = "t2.medium"
}

variable "aws_instance_type" {
  default = "m4.xlarge"
}

variable "aws_ami_user" {
  default = "centos"
}

variable "aws_key_pair_name" {
  default = "example_iam_keypair"
}

variable "aws_key_pair_file" {
  default = "~/.ssh/example.pem"
}

variable "automate_es_recipe" {
  default = "recipe[backend_search_cluster::search_es]"
}

# Tagging
variable "automate_tag" { default = "terraform_automate" }
variable "tag_dept" { default = "SCE" }
variable "tag_contact" { default = "irving" }

# Basic AWS info
provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}" // uses ~/.aws/credentials by default
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-201706012343"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["446539779517"]
}
