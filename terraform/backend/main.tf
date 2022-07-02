terraform {
  required_providers {
    google = {
      source  = "google"
      version = "4.27.0"
    }
  }
}

variable "gcp_project" {
  type = string
}
variable "gcp_region" {
  type = string
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# terraform import google_storage_bucket.tfstate tfstate-poc-backstage
resource "google_storage_bucket" "tfstate" {
  name     = "backstage-gcs"
  location = var.gcp_region
}
