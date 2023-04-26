terraform {
  cloud {
    organization = "N4K"

    workspaces {
      name = "1_Github-GCP-Bastion-Instance"
    }
  }
  
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.10"
    }
  }
}

provider "google" {
  project     = var.project_name
  region      = var.region
  credentials = var.gcp_credentials
}

provider "github" {
  token = var.GITHUB_SECRET
  owner = var.GITHUB_OWNER
}
