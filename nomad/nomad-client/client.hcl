# sudo nano /etc/nomad.d/nomad.hcl

client {
  enabled = true
  servers = ["192.168.122.11:4647","192.168.122.12:4647","192.168.122.13:4647"]
  # IPs de los servidores Nomad a los que se va a conectar este cliente
  server_join {
    retry_join = ["192.168.122.11", "192.168.122.12", "192.168.122.13"]
  }
}
datacenter = "dc1"
region     = "global"

bind_addr = "0.0.0.0"
data_dir  = "/opt/nomad"

consul {
  address        = "127.0.0.1:8500"
  auto_advertise = true
  
  # Permite que Nomad registre automáticamente los servicios de los jobs en Consul
  client_auto_join = true
}

telemetry {
  collection_interval = "15s"
  
  # Habilita el formato nativo que entiende Prometheus
  prometheus_metrics = true
  
  # Permite que las métricas del runtime de Nomad se publiquen
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
