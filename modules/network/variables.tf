variable "gcp_project" {
    type = string
}

variable "key_path" {
    type = string
}

variable "project_zone" {
    type = string
}

variable "network_name" {
    type = string
    default = "my-network"
}

variable "subnetwork_name" {
    type = string
    default = "my-subnetwork"
}

variable "subnet_region" {
    type = string
    default = "us-central1"
}

variable "router_name" {
    type = string
    default = "my-router"
}
