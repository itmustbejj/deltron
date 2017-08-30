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

