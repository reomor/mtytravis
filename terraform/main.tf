provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata_item" "appuser1" {
  key = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}"
}

resource "google_compute_project_metadata_item" "appuser2" {
  key = "ssh-keys"
  value = "appuser2:${file(var.public_key_path)}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  count = "${var.count}"

  tags = ["reddit-app"]

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

  network_interface {
    # network to connect
    network = "default"

    # use ephemeral IP
    access_config {}
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # network name, where rule is active
  network = "default"

  # allowed port
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # allowed addresses
  source_ranges = ["0.0.0.0/0"]

  # instance tags, where rule is active
  target_tags = ["reddit-app"]
}
