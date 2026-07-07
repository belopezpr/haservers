# Ejercicio de balanceo de carga servidores web
Se instalan 3 nodos: 1 HAProxy (balanceador) 2 nginx (servidores web)

Ver [Crear nodo VMWare](crear_nodo_vmware.md)

1. en los nodos nginx modificar el archivo index.html para visualizar facilmente el nodo al que se esta accediendo
ejemplo
para editar se puede usar el comando "nano" 
`sudo nano /var/wwww/html/index.debian.html` 
en algunas versiones el path del archivo es
`sudo nano /usr/share/nginx/index.html`

para grabar el archivo presionar alt+x preguntara si desea guardar presione Y o S, luego muestra el nombre del archivo solo dar Enter

reiniciar el servicio de nginx para que tome los cambios
`sudo service nginx restart`

2. en el nodo haproxy modificar el archivo haproxy.cfg usualmente en /etc/haproxy
`sudo nano /etc/haproxy/haproxy.cfg` 

```
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
    server node01 192.168.122.41:80 check
    server node02 192.168.122.42:80 check
```
tomar nota que las ip a utilizar deben ser de los nodos que se configuran como servidores web

reiniciar el servicio de haproxy
`sudo service haproxy restart`

3. desde el equipo configurado como cliente puede ser un nodo 4 instalar las herramientas wrk y hey que serviran para generar estres en el balanceador
`sudo apt update`
`sudo apt install wrk hey`

4. generacion de estres en el balanceador
usar los comandos
`wrk -t4 -c100 -d30s http://<ip del balanceador>:8080`
`hey -z 30s -c 100 http://<ip del balanceador>:8080`

5. hacer pruebas agregando un tercer nodo
6. desde un navegador acceder a la ip del balanceador en el puerto 8080 mientra hay estres para visualizar los resultados
7. habilite las estadisticas de haproxy en el puerto 3000
8. habilite la autenticacion para ver estadisticas
9. Analice en que casos es factible usar haproxy como balanceador de peticiones para bases de datos