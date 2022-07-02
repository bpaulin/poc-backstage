terraform {
  required_providers {
    google = {
      source  = "google"
      version = "4.27.0"
    }
    random = {
      source  = "random"
      version = "3.3.2"
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

terraform {
  backend "gcs" {
    bucket = "backstage-gcs"
    prefix = "tfstate"
  }
}

resource "google_redis_instance" "cache" {
  name           = "backstage-redis"
  memory_size_gb = 1
}

resource "random_string" "dbname" {
  length  = 4
  upper   = false
  special = false
}

resource "google_sql_database" "database" {
  name     = "backstage-db"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name                = "backstage-db-instance-${random_string.dbname.result}"
  database_version    = "POSTGRES_14"
  deletion_protection = false
  settings {
    tier      = "db-f1-micro"
    disk_type = "PD_HDD"
  }
}

resource "google_container_cluster" "primary" {
  name             = "backstage-gke"
  location         = var.gcp_region
  enable_autopilot = true
  ip_allocation_policy {}
}

