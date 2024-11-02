output "website_url" {
  description = "The external IP address of the website instance"
  value       = google_compute_instance.website_instance.network_interface[0].access_config[0].nat_ip
}

output "static_ip_address" {
  description = "The static IP address assigned to the instance"
  value       = google_compute_address.static_ip.address
}

