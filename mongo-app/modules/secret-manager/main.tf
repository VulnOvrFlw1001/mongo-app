terraform {
    backend "gcs" {
      bucket = "mongo-app-bucketzz"
      prefix = "secrets-manager"
      credentials = "C:\\Users\\hansj\\Downloads\\terraform-course-key.json"
    }
    required_providers {
      google = {
        source = "hashicorp/google"
        version = "5.42.0"
      }
      random = {
        source = "hashicorp/random"
        version = "3.4.3"
      }
    }
}

provider "google" {
    project = var.gcp_project
    credentials = file(var.key_path)
    zone = var.project_zone
}

resource "google_secret_manager_secret" "secret_manager" {
    secret_id = var.secret_manager_name
    replication {
        user_managed {
            replicas {
                location = var.region
            }
        }
    }
}

resource "random_password" "password" {
    length = 15
    min_lower = 5
    min_numeric = 5
    min_upper = 5
}

resource "google_secret_manager_secret_version" "version" {
    secret = google_secret_manager_secret.secret_manager.id
    secret_data = random_password.password.result
    deletion_policy = "DELETE"
}

resource "google_service_account" "secret_manager_service_account" {
    account_id = var.secret_manager_service_account_name
    project = var.gcp_project
    display_name = var.secret_manager_service_account_name
}

resource "google_project_iam_binding" "iam_binding" {
    project = var.gcp_project
    role = "roles/secretmanager.secretAccessor"
    members = [
        "serviceAccount:${google_service_account.secret_manager_service_account.email}"
    ]
}

data "google_iam_policy" "policy" {
    binding {
        role = "roles/iam.workloadIdentityUser"

        members = [
            "serviceAccount:${var.gcp_project}.svc.id.goog[external-secrets/external-secrets-sa]"
        ]
    }
}

resource "google_service_account_iam_policy" "workload_identity" {
    service_account_id = google_service_account.secret_manager_service_account.name
    policy_data = data.google_iam_policy.policy.policy_data
}