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

5. Edirar en el servidor Consul el archivo consul.d
```
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
```

6. reiniciar el servicio consul
`sudo service consul restart`


7. Editar en el servidor Vault el archivo consul.d
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

8. Editar el servidor Vault el archivo vault.hcl
```
# sudo nano /etc/vault.d/vault.hcl

storage "consul" {
  # Habla con el agente de Consul local en la misma VM
  address = "127.0.0.1:8500"
  path    = "vault/"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

# Apuntar a la IP real de la VM de Vault
api_addr     = "http://192.168.122.31:8200"
cluster_addr = "http://192.168.122.31:8201"
```

9. Reiniciar los servicios en el servidor Vault
`sudo service consul restart`
`sudo service vault restart`

10. Editar en cada cliente Nomad el archivo consul.d
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

11. Editar en cada cliente Nomad el archivo nomad.hcl
```
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

plugin "nomad-driver-podman" {
  config {
    # Habilita el modo rootless si no usas sudo para Podman
    # rootless = true
    
    # Tiempo de espera para comunicarse con el socket de Podman
    #socket_timeout = "20s"
    
    # Apunta al socket del host montado dentro del contenedor
    socket_path = "unix:///run/user/1000/podman/podman.sock"
  }
}
```

12. Reiniciar los servicios nomad y consul en cada cliente Nomad
`sudo service consul restart`
`sudo service nomad restart`