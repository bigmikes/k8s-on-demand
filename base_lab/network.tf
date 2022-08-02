resource "google_compute_network" "vpc_network" {
  name                    = "k8s-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "k8s-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_all_ingress" {
  name          = "allow-all-ingress"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-all"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "allow_all_egress" {
  name          = "allow-all-egress"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-all"]
  destination_ranges = ["0.0.0.0/0"]
  direction = "EGRESS"

  allow {
    protocol = "all"
  }
}