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

