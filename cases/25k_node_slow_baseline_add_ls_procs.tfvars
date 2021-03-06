automate_instance_id = "25k_node_slow_baseline_add_ls_procs"
tag_test_id = "25k_node_slow_baseline_add_ls_procs"
aws_instance_type = "m4.4xlarge"
chef_load_rpm = "834"
automate_es_recipe = "recipe[backend_search_cluster::search_es]"
external_es_count = 3
logstash_total_procs = 8
logstash_heap_size = "2g"
logstash_bulk_size = "512"
es_index_shard_count = 3
es_max_content_length = "1gb"
#ebs_iops = 300
