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

resource "google_container_cluster" "primary" {
    name = var.cluster_name
    location = var.cluster_location
    network = var.cluster_network
    subnetwork = var.cluster_subnetwork

    remove_default_node_pool = true
    initial_node_count = 1

    private_cluster_config {
      enable_private_endpoint = false
      enable_private_nodes = true
      master_ipv4_cidr_block = var.master_ipv4_cidr_block
      master_global_access_config {
        enabled = true
      }
    }

    maintenance_policy {
      recurring_window {
        recurrence = "FREQ=DAILY"
        start_time = "2024-10-10T02:00:00Z"
        end_time = "2024-10-10T06:00:00Z"
      }
    }

    ip_allocation_policy {
      cluster_ipv4_cidr_block = var.pods_ip_cidr_block
      services_ipv4_cidr_block = var.services_ip_cidr_block
    }

    logging_config {
      enable_components = [ "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER" ]
    }

    logging_service = "logging.googleapis.com/kubernetes"
}