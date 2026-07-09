# Pasos para configuración de Nomad

1. Estructura
Cantidad de servidores Nomad: 3
Cantidad de servidores Consul: 1
Cantidad de servidores Vault: 1
Cantidad de servidores Nomad client: 3

2. Editar en los 3 servidores nomad el archivo consul.hcl
```
# /etc/consul.d/consul.hcl en cada nodo Nomad

data_dir    = "/opt/consul"
datacenter  = "dc1"
server      = false  # Mantiene al nodo como cliente, no servidor

# Direcciones de escucha
bind_addr   = "192.168.122.X" # ip de la vm
client_addr = "127.0.0.1"    # Permite que Nomad lo encuentre en localhost

# Unirse automáticamente al servidor central de Consul
retry_join  = ["192.168.122.21"]
```

3. Editar en los 3 servidores nomad el archivo nomad.hcl
```
# sudo nano /etc/nomad.d/nomad.hcl

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
``` 

4. reiniciar los servicios nomad y consul en los 3 servidores
```
sudo service consul restart
sudo service nomad restart
```



