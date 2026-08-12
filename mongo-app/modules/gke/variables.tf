variable "gcp_project" {
    type = string
}

variable "key_path" {
    type = string
}

variable "project_zone" {
    type = string
}

variable "cluster_name" {
    type = string
    default = "my-cluster"
}

variable "cluster_location" {
    type = string
    default = "us-central1-a"
}

variable "cluster_network" {
  type = string
  default = "my-network"
}

variable "cluster_subnetwork" {
    type = string
    default = "my-subnetwork"
}

variable "master_ipv4_cidr_block" {
    type = string
    #default = "172.16.0.0/12"
    default = "170.16.0.32/28"
}

variable "pods_ip_cidr_block" {
    type = string
    default = "192.168.10.0/24"
}

variable "services_ip_cidr_block" {
    type = string
    default = "192.168.20.0/24"
}

variable "node_pool_name" {
    type = string
    default = "my-node-pool"
}

variable "node_autoscaler" {
    type = object({
        enabled = bool
        min_count = number
        max_count = number
    })
    default = {
        enabled = true
        min_count = 0
        max_count = 4
    }
}

variable "node_config" {
    type = object({
        image_type = string
        disk_type = string
        disk_size_gb = number
        machine_type = string
    })
    default = {
        image_type = "cos_containerd"
        machine_type = "e2-medium"
        disk_size_gb = 100
        disk_type = "pd-standard"
    }
}

variable "logging_bucket_name" {
    type = string
    default = "my-logging-bucket-kubernetes-core-components"
}

variable "kubernetes_logging_components" {
    type = set(string)
    default = [ "apiserver", "scheduler", "control-manager" ]
}