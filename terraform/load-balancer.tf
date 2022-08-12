resource "google_compute_global_address" "ext_lb_ip" {
  name = "tcp-proxy-xlb-ip"
}

resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l4-ilb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  all_ports             = true
  target                = google_compute_target_tcp_proxy.target_tcp_proxy.id
  ip_address            = google_compute_global_address.ext_lb_ip.id
}

resource "google_compute_target_tcp_proxy" "target_tcp_proxy" {
  name            = "tcp-proxy-health-check"
  backend_service = google_compute_backend_service.k8s_cp_service.id
}

resource "google_compute_backend_service" "k8s_cp_service" {
  name                  = "tcp-proxy-xlb-backend-service"
  protocol              = "TCP"
  port_name             = "tcp-k8s-api"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.k8s_api_health_check.id]
  backend {
    group           = google_compute_instance_group_manager.cp-instance-group.instance_group
    balancing_mode  = "CONNECTION"
  }
}

resource "google_compute_health_check" "k8s_api_health_check" {
  name               = "tcp-proxy-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "6443"
  }
}