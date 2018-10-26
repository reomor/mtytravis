provider "google" {
  version = "1.4.0"
  project = "steadfast-slate-219116"
  region  = "europe-west1"
}

resource "google_compute_instance" "app" {
  name	       = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west1-b"

  tags = ["reddit-app"]
  
  metadata {
    ssh-keys = "reomor:${file("~/.ssh/reomor.pub")}"
  }
  
  boot_disk {
    initialize_params {
      image = "reddit-base"
    }
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
    ports = ["9292"]
  }
  # allowed addresses
  source_ranges = ["0.0.0.0/0"]
  # instance tags, where rule is active
  target_tags = ["reddit-app"]
}
