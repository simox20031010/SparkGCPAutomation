# ----------------------------
# Networking: VPC + Subnet
# ----------------------------
resource "google_compute_network" "spark_vpc" {
  name                    = "spark-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "spark_subnet" {
  name          = "spark-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.spark_vpc.id
}

# ----------------------------
# Firewall rules
# ----------------------------

# SSH access (recommend: set allow_ssh_cidr to YOUR_IP/32)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.spark_vpc.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.allow_ssh_cidr]
  target_tags   = ["spark-node"]
}

# Internal traffic inside subnet (Spark cluster communication)
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.spark_vpc.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
  target_tags   = ["spark-node"]
}

# Spark Web UIs (optional but useful for demo)
resource "google_compute_firewall" "allow_spark_ui" {
  name    = "allow-spark-ui"
  network = google_compute_network.spark_vpc.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["8080", "8081"]
  }

  source_ranges = [var.allow_ssh_cidr]
  target_tags   = ["spark-node"]
}

# ----------------------------
# Compute Instances: master, edge, workers
# ----------------------------

# Common OS image (Debian 12)
data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_instance" "spark_master" {
  name         = "spark-master"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["spark-node", "spark-master"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {}
  }

  metadata = {
    # You can add SSH keys later (recommended) or use OS Login
  }
}

resource "google_compute_instance" "spark_edge" {
  name         = "spark-edge"
  machine_type = "e2-small"
  zone         = var.zone
  tags         = ["spark-node", "spark-edge"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {}
  }

  metadata = {}
}

resource "google_compute_instance" "spark_workers" {
  count        = var.workers_count
  name         = "spark-worker-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["spark-node", "spark-worker"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {}
  }

  metadata = {}
}
