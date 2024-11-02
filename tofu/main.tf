# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Configure the GCS backend
terraform {
  backend "gcs" {
    bucket = var.tf_state_bucket
    prefix = "terraform/state"
  }
}

# Create a GCP Compute Engine instance
resource "google_compute_instance" "website_instance" {
  name         = local.instance_name
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    gce-container-declaration = templatefile("${path.module}/container-spec.yaml", {
      docker_image = var.docker_image
    })
  }

  tags = ["http-server", "https-server"]
}

# Create a static IP address
resource "google_compute_address" "static_ip" {
  name = local.static_ip_name
}

# Allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "${local.firewall_rule_name}-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Allow HTTPS traffic
resource "google_compute_firewall" "allow_https" {
  name    = "${local.firewall_rule_name}-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

# Create a global IP address for the load balancer
resource "google_compute_global_address" "default" {
  name = "global-website-ip"
}

# Create the managed SSL certificate
resource "google_compute_managed_ssl_certificate" "default" {
  name = "website-cert"

  managed {
    domains = [var.domain_name]
  }
}

# Create the HTTPS load balancer
resource "google_compute_target_https_proxy" "default" {
  name             = "website-target-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# Create a URL map
resource "google_compute_url_map" "default" {
  name            = "website-url-map"
  default_service = google_compute_backend_service.default.id
}

# Create a backend service
resource "google_compute_backend_service" "default" {
  name        = "website-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.default.id]

  backend {
    group = google_compute_instance_group.webservers.id
  }
}

# Create a health check
resource "google_compute_health_check" "default" {
  name               = "website-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = 80
  }
}

# Create an instance group
resource "google_compute_instance_group" "webservers" {
  name        = "website-instance-group"
  description = "Web servers instance group"
  zone        = var.zone

  instances = [
    google_compute_instance.website_instance.id,
  ]

  named_port {
    name = "http"
    port = 80
  }
}

# Create a global forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name       = "website-forwarding-rule"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}
