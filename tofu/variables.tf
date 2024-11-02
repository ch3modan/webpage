variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The zone to deploy resources to"
  type        = string
  default     = "europe-west4-a"
}

variable "machine_type" {
  description = "The machine type for the Compute Engine instance"
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_image" {
  description = "The boot disk image for the Compute Engine instance"
  type        = string
  default     = "cos-cloud/cos-stable"
}

variable "docker_image" {
  description = "The full name of your Docker image on Docker Hub (e.g., 'username/image:tag')"
  type        = string
  default     = "thatbagu/website"
}

variable "tf_state_bucket" {
  description = "The name of the GCS bucket for Terraform state"
  type        = string
  default     = "tofu-state-243"
}

variable "domain_name" {
  description = "The domain name for the website"
  type        = string
  default     = "kosaretsky.co.uk"
}

variable "static_ip_name" {
  description = "The name for the static IP address"
  type        = string
  default     = "website-static-ip"
}

variable "firewall_rule_name" {
  description = "The name for the firewall rule"
  type        = string
  default     = "allow-http-https"
}

variable "instance_name" {
  description = "The name for the Compute Engine instance"
  type        = string
  default     = "website-instance"
}

variable "instance_group_name" {
  description = "The name for the instance group"
  type        = string
  default     = "website-instance-group"
}

variable "load_balancer_name" {
  description = "The name for the load balancer"
  type        = string
  default     = "website-load-balancer"
}

variable "ssl_certificate_name" {
  description = "The name for the managed SSL certificate"
  type        = string
  default     = "website-ssl-cert"
}
