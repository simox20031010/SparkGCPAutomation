output "edge_public_ip" {
  value       = google_compute_instance.spark_edge.network_interface[0].access_config[0].nat_ip
  description = "Public IP of the edge node"
}

output "master_public_ip" {
  value       = google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip
  description = "Public IP of the master node"
}

output "workers_public_ips" {
  value       = [for w in google_compute_instance.spark_workers : w.network_interface[0].access_config[0].nat_ip]
  description = "Public IPs of worker nodes"
}
