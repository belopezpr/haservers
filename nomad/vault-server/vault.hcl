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