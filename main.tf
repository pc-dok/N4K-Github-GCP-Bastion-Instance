#######################################################################
# Creates all GCP resources                                           #
#######################################################################

# Enable Compute Engine API for the project
resource "google_project_service" "compute_engine_api" {
  service       = "compute.googleapis.com"
  project       = var.GCP_PROJECT
}

#######################################################
# Creates a VPC and custom Subnet                     #
#######################################################

resource "google_compute_network" "vpc" {
  name                    = var.vpc1
  project                 = var.GCP_PROJECT
  auto_create_subnetworks = false
  description             = "VPC1 for Servers"
  depends_on              = [google_project_service.compute_engine_api]
}

resource "google_compute_subnetwork" "subnet" {
  name            = "${var.vpc1}-subnet-01"
  project         = var.GCP_PROJECT
  network         = google_compute_network.vpc.self_link
  ip_cidr_range   = var.cidr-gcp
  region          = var.region
  description     = "Server SN"
}

###################################################################################
# Creates a GCP Cloud NAT for having Internet available on all VM Instances later #
###################################################################################

resource "google_compute_router" "router" {
  name    = "${var.vpc1}-router-01"
  project = var.GCP_PROJECT
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc1}-router-nat-01"
  project                            = var.GCP_PROJECT
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
