provider "google" {
  version = "1.4.0"
  project = "steadfast-slate-219116"
  region  = "europe-west1"
}

resource "google_compute_instance" "app" {
  name	       = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  
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
