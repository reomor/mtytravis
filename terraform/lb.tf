resource "google_compute_instance_group" "app-cluster" { 
    name  = "app-cluster" 
    description = "Terraform test instance group" 

    instances = [ 
      "${google_compute_instance.app.self_link}",
      "${google_compute_instance.app2.self_link}"
    ] 

    named_port { 
      name = "puma" 
      port = "9292" 
    } 

    zone = "${var.zone}"
}

resource "google_compute_health_check" "puma-health-check" { 
    name    = "puma-health-check" 
    check_interval_sec = 5 
    timeout_sec  = 5 

    tcp_health_check { 
      port = "9292" 
    } 
}

resource "google_compute_backend_service" "puma-backend" {
  name        = "puma-backend"
  description = "Our company website"
  protocol    = "HTTP"
  port_name = "puma"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.app-cluster.self_link}"
  }

  health_checks = ["${google_compute_health_check.puma-health-check.self_link}"]
}

resource "google_compute_url_map" "reddit_url_map" {
  name            = "reddit-url-map"
  default_service = "${google_compute_backend_service.puma-backend.self_link}"
}

resource "google_compute_target_http_proxy" "reddit_proxy" {
  name    = "reddit-proxy"
  url_map = "${google_compute_url_map.reddit_url_map.self_link}"
}

resource "google_compute_global_forwarding_rule" "reddit_rule" {
  name       = "reddit-rule"
  target     = "${google_compute_target_http_proxy.reddit_proxy.self_link}"
  port_range = "80"
}
