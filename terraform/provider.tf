terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "google" {
  credentials = file(var.credential_file_path)

  project = "k8s-course-351222"
  region  = "us-central1"
  zone    = "us-central1-c"
}