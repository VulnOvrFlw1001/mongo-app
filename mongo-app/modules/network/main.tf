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
    region = var.region
    ip_cidr_range = var.ip_cidr_range
}

resource "google_compute_router" "router" {
    name = var.router_name
    network = google_compute_network.network.name
    project = var.gcp_project
    region = var.region
}

resource "google_compute_router_nat" "nat" {
    project = var.gcp_project
    region = var.region
    name = var.nat_name
    router = google_compute_router.router.name
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name = google_compute_subnetwork.subnetwork.name
        source_ip_ranges_to_nat = [ "ALL_IP_RANGES" ]
    }
    nat_ip_allocate_option = "AUTO_ONLY"
}