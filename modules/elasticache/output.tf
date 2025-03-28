output "cluster_endpoint" {
  value = aws_elasticache_cluster.e2e-project-elasticache-cluster.cache_nodes[0].address
}

output "cluster_port" {
  value = aws_elasticache_cluster.e2e-project-elasticache-cluster.cache_nodes[0].port
}
