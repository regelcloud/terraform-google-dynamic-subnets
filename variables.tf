variable "project" {
}

variable "name" {
  default = "dynamic-subnet"
}

variable "region" {
  default = "us-central1"
}

variable "network" {
}

variable "base_cidr" {
  type    = string
  default = "10.190.0.0/22"
}

