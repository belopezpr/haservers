server {
  enabled = true
  bootstrap_expect = 3
}
bind_addr = "0.0.0.0"
data_dir  = "/opt/nomad"
disable_update_check = true
advertise {
  http = "192.168.122.11:4646"
  rpc  = "192.168.122.11:4647"
  serf = "192.168.122.11:4648"
}
retry_join = ["192.168.122.11","192.168.122.12","192.168.122.13"]
consul {
  address             = "127.0.0.1:8500"
  server_service_name = "nomad"
  auto_advertise      = true
  server_auto_join    = true
  client_auto_join    = true
}
telemetry {
  collection_interval = "15s"
  
  # Habilita el formato nativo que entiende Prometheus
  prometheus_metrics = true
  
  # Permite que las métricas del runtime de Nomad se publiquen
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

