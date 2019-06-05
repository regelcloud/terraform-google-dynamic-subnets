# terraform {
#   required_version = "~> 0.12"

#   # backend "gcs" {}

#   required_providers {
#     google      = "~> 2.5"
#     google-beta = "~> 2.5"
#   }
# }

# Google Provider info
##########################################################
provider "google" {
  version = "~> 2.5"
  region  = var.region
}

# Get GCP metadata from local gcloud config
##########################################################
data "google_client_config" "gcloud" {
}

data "google_compute_zones" "available" {
  project = var.project
}

data "google_compute_network" "subnetworks" {
  project = var.project
  name = var.name
}

# data "google_compute_subnetwork" "subnetwork" {
#   name = "${var.name}-${local.subnetworks-count}"
# }

# VPCs
##########################################################
resource "google_compute_network" "vpc" {
  count                   = var.network != "" ? 0 : 1
  name                    = var.name
  project                 = var.project
  auto_create_subnetworks = "false"
}

data "google_compute_network" "vpc" {
  count   = var.network != "" ? 1 : 0
  project = var.project
  name    = var.network
}

locals {
  vpc_network_self_link = element(
    concat(
      data.google_compute_network.vpc.*.self_link,
      google_compute_network.vpc.*.self_link,
    ),
    0,
  )
}


data "terraform_remote_state" "state" {
  backend = "local"
}

## logic

# 1. check if ressource created and exists in statefile
# 2. check data for subnetworks
# 3. add new subnetworks

##
locals {
  subnetworks-count = coalesce(data.google_compute_network.subnetworks.subnetworks_self_links == null ?  0 : ( "${data.terraform_remote_state.state.outputs}" == {} ? length(data.google_compute_network.subnetworks.subnetworks_self_links) : "${data.terraform_remote_state.state.outputs.subnetworks}" )) #length(data.google_compute_network.subnetworks.subnetworks_self_links))
}



output "subnetworks" {
  value = "${local.subnetworks-count}"
    depends_on = [
    google_compute_subnetwork.subnet,
  ]
}

# Subnets
##########################################################
resource "google_compute_subnetwork" "subnet" {
  name        = "${var.name}-${local.subnetworks-count}"
  project     = var.project
  network     = local.vpc_network_self_link # https://github.com/terraform-providers/terraform-provider-google/issues/1792
  region      = var.region
  description = "This is dynamic n/w"
  ip_cidr_range            = cidrsubnet(var.base_cidr, 2, local.subnetworks-count)
  private_ip_google_access = true
}

