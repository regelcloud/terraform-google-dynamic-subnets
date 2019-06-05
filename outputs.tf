
output "subnetworks" {
  value = "${local.subnetworks-count}"
    depends_on = [
    google_compute_subnetwork.subnet,
  ]
}
