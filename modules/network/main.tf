terraform {
  backend "gcs" {
    bucket = "mongo-app-bucketzz"
    prefix = "modules"
    credentials = "C:\\Users\\hansj\\Downloads\\terraform-course-key.json"
  }
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "5.42.0"
    }
  }
}

provider "google"{
    project = var.gcp_project
    credentials = file(var.key_path)
    zone = var.project_zone
}

resource "google_compute_network" "network" {
    name = var.network_name 
    project = var.gcp_project
    description = "VPC managed by Terraform"
    auto_create_subnetworks = false
    network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"

}

resource "google_compute_subnetwork" "subnetwork" {
    name = var.subnetwork_name
    network = google_compute_network.network.name
    description = "Subnet managed by Terraform"
    purpose = "PRIVATE"
    stack_type = "IPV4_ONLY"
    region = var.subnet_region
}

resource "google_compute_router"