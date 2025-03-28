variable "vpc_id" {
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ElastiCache"
  type        = list(string)
}

variable "elasticache_sg" {
  type        = string
}

variable "engine" {
  type = string
}
variable "engine_version" {
  type        = string
}

variable "node_type" {
  type        = string
}

variable "num_cache_nodes" {
  type        = number
}

variable "cluster_id" {
  type        = string
}
variable "security_group_id" {
  type = string
}