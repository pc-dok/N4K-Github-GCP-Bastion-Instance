# Define variables

variable "GITHUB_SECRET" {}
variable "GITHUB_OWNER" {}
variable "GCP_Bastion_FQDN" {}
variable "GCP_Bastion_DN" {}
variable "GCP_Bastion_CERT_Country" {}
variable "GCP_Bastion_CERT_Location" {}
variable "GCP_Bastion_CERT_ORG" {}
variable "GCP_Bastion_Email" {}

variable "gcp_credentials" {
  type = string
  sensitive = true
  description = "Google Cloud service account credentials"
}

variable "GCP_Bastion_PW" {
  type = string
  sensitive = true
  description = "Guacamole MySQL Password"
}

variable "GCP_Bastion_Admin_PW" {
  type = string
  description = "Local Windows Admin Password"
}

variable "admin_name" {
  type        = string
  description = "Local Admin User"
  default     = "localadm"
}

variable "project_name" {
  type        = string
  description = "Name of the Google Cloud project"
  default     = "n4k-bastion-01"
}

variable "GCP_PROJECT" {
  type = string
  description = "Name of the Google Cloud project"
  default     = "n4k-bastion-01"
}

variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "europe-west1"
}

variable "zone" {
  type        = string
  description = "Name of the GCP zone"
  default     = "europe-west1-b"
}

variable "billingid" {
  type        = string
  description = "Name of your billing ID"
  default     = "010428-E6DD63-4DB186"
}

variable "vpc1" {
  type        = string
  description = "Name of your VPC Network"
  default     = "n4k-vpc-we-001"
}

variable "cidr-gcp" {
        type    = string
        default = "172.21.2.0/24"
    }

variable "tf_service_account" {
        type    = string
        default = "sa-bastion-instance@n4k-bastion-01.iam.gserviceaccount.com"
    }
