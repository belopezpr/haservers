# sudo nano /etc/consul.d/consul.hcl

server = true
bootstrap_expect = 1
data_dir = "/opt/consul"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

ui_config {
  enabled = true
}

telemetry {
  prometheus_retention_time = "72h"
  disable_hostname          = true
}