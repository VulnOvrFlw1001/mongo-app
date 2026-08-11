terraform {
  backend "gcs" {
    bucket = "mongo-app-bucketzz"
    prefix = "gke"
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
      enable_components = [ "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER", "SYSTEM_COMPONENTS" ]
    }
}

resource "google_container_node_pool" "node_pool" {
    name = var.node_pool_name
    cluster = google_container_cluster.primary.name
    location = var.cluster_location

    initial_node_count = 1
    autoscaling {
      max_node_count = var.node_autoscaler["enabled"] == true ? var.node_autoscaler["max_count"] : null
      min_node_count = var.node_autoscaler["enabled"] == true ? var.node_autoscaler["min_count"] : null

    }
    management {
      auto_repair = true
      auto_upgrade = true
    }
    upgrade_settings {
      max_surge = 1
      max_unavailable = 1
    }
    node_config {
      machine_type = var.node_config["machine_type"]
      image_type = var.node_config["image_type"]
      disk_size_gb = var.node_config["disk_size_gb"]
      disk_type = var.node_config["disk_type"]
    }
}

resource "google_storage_bucket" "logging_bucket" {
  name = var.logging_bucket_name
  location = "US"
  public_access_prevention = "enforced"
  storage_class = "STANDARD"
  soft_delete_policy {
    retention_duration_seconds = 604800
  }
}

resource "google_logging_project_sink" "sink" {
  for_each = var.kubernetes_logging_components
  name = "my-logging-sink-${each.value}"
  destination = "storage.googleapis.com/${google_storage_bucket.logging_bucket.name}"
  filter = "resource.type=\"k8s_control_plane_component\" resource.labels.component_name=\"${each.value}\" resource.labels.location=\"${google_container_cluster.primary.location}\" resource.labels.cluster_name=\"${google_container_cluster.primary.name}\""
  unique_writer_identity = false 
}

resource "google_project_iam_binding" "binding" {
  project = var.gcp_project
  role = "roles/storage.objectCreator"

  members = [
    "serviceAccount:cloud-logs@system.gserviceaccount.com"
  ]
}