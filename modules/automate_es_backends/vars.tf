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

variable "automate_es_recipe" {
  default = "recipe[backend_search_cluster::search_es]"
}
