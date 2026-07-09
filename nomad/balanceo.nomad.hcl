job "laboratorio-balanceo" {
  datacenters = ["dc1"]
  type        = "service"

  # ==========================================
  # GRUPO 1: LOS TRES SERVIDORES NGINX (ESTÁTICOS)
  # ==========================================
  group "servidores-web" {
    count = 3 # Uno para cada Nomad Client

    constraint {
      distinct_hosts = true
    }

    network {
      # FORZAMOS a que Nomad reserve el puerto 80 real de la máquina host
      port "http" {
        static = 80
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:alpine"
        # Mapeo explícito: Puerto 80 del Host -> Puerto 80 del Contenedor
        ports = ["http"]
        
        volumes = [
          "local/index.html:/usr/share/nginx/html/index.html"
        ]
      }

      template {
        data        = "Hola desde Nginx corriendo en el Cliente IP: {{ env \"NOMAD_IP_http\" }}. Instancia: {{ env \"NOMAD_ALLOC_ID\" }}"
        destination = "local/index.html"
      }
      
      # Nota: Quitamos el bloque 'service' de Consul para que Nomad 
      # se encargue puramente de levantar el contenedor sin añadir fricción de Health Checks externos.
    }
  }

  # ==========================================
  # GRUPO 2: EL BALANCEADOR HAPROXY (ESTÁTICO)
  # ==========================================
  group "balanceador" {
    count = 1 # Se ejecutará en uno de los clientes

    network {
      # FORZAMOS el puerto 8080 en el Host
      port "lb" {
        static = 8080
      }
    }

    task "haproxy" {
      driver = "docker"
      
      config {
        image = "haproxy:alpine"
        ports = ["lb"]
        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
        ]
      }

      template {
        # Configuramos el pool de Nginx apuntando directamente a las IPs fijas de tus 3 clientes en el puerto 80
        data = <<EOH
global
    log stdout format raw local0

defaults
    log     global
    mode    http
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend http_front
    bind *:8080
    default_backend nginx_pool

backend nginx_pool
    balance roundrobin
    server node01 192.168.152.136:80 check
    server node02 192.168.152.137:80 check
    server node03 192.168.152.138:80 check
EOH
        destination = "local/haproxy.cfg"
      }
    }
  }
}