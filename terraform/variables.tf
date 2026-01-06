variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west1-b"
}

variable "workers_count" {
  description = "Number of Spark workers"
  type        = number
  default     = 2
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "allow_ssh_cidr" {
  description = "CIDR allowed to SSH (your public IP/32 recommended)"
  type        = string
  default     = "0.0.0.0/0"
}

