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
    default = "170.16.0.32/28"
}

variable "pods_ip_cidr_block" {
    type = string
    default = "192.168.10.0/24"
}

variable "services_ip_cidr_block" {
    type = string
    default = "192.168.10.0/24"
}