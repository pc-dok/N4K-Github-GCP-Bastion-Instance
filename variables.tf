# Define variables
variable "project_name" {
  type        = string
  description = "Name of the Google Cloud project"
  default     = "n4k-project-012"
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
