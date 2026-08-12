variable "gcp_project" {
    type = string
}

variable "key_path" {
    type = string
}

variable "project_zone" {
    type = string
}

variable "secret_manager_name"{
    type = string
    default = "my-secret-manager"
}

variable "region" {
    type = string
    default = "us-central1"
}

variable "secret_manager_service_account_name"{
    type = string
    default = "my-secret-manager-sa"
}