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