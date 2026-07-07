# Creacion de maquina virtual (nodo) desde archivo ova de ubuntu
1. Descargar archivo .ova desde https://cloud-images.ubuntu.com/noble/current/
noble-server-cloudimg-amd64.ova 

2. En VMWare Workstation ir a la opcion de File/Open y seleccionar archivo .ova
3. Primer formulario ingresar nombre de la vm
4. Segundo formulario ingresar nombre del host e ingresar configuraciones iniciales en formato base64
  a) Configuracion user-data debe estar en la siguiente sintaxis yaml

```
#cloud-config
hostname: nodoha
fqdn: nodoha.lab
ssh_pwauth: True

user:
  name: ubuntu
  lock_passwd: false

users:
  - default
  - name: laboratorio
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: [sudo, admin]
    shell: /bin/bash
    lock_passwd: false

chpasswd:
  list: |
    ubuntu:Pwd123!
    laboratorio:$6$RlPGYuq3r2/e6O4M$k2icr.2RXN75qQjnWH/vTIBtRo8a4yJ.cEptj137iyI.B0ipGJ5IOwv5AhW334kh.9Cw9uAwtaT9NjgeKPtec1
  expire: False

runcmd:
  - apt-get update
  - apt-get install -y haproxy
  - [ systemctl, restart, haproxy ]
```

  b) puede utilizar la siguiente pagina para convertir el texto yaml a base64 https://www.base64encode.org/
  c) copiar el texto encode que debe verse como sigue
```
I2Nsb3VkLWNvbmZpZwpob3N0bmFtZTogbm9kb2hhCmZxZG46IG5vZG9oYS5sYWIKc3NoX3B3YXV0aDogVHJ1ZQoKIyBNb2RpZmljYW1vcyBlbCB1c3VhcmlvIHBvciBkZWZlY3RvIGRlbCBzaXN0ZW1hICh1YnVudHUpCnVzZXI6CiAgbmFtZTogdWJ1bnR1CiAgbG9ja19wYXNzd2Q6IGZhbHNlCgojIERlZmluaW1vcyBsb3MgdXN1YXJpb3MgZGVsIHNpc3RlbWEKdXNlcnM6CiAgLSBkZWZhdWx0CiAgLSBuYW1lOiBsYWJvcmF0b3JpbwogICAgc3VkbzogWydBTEw9KEFMTCkgTk9QQVNTV0Q6QUxMJ10KICAgIGdyb3VwczogW3N1ZG8sIGFkbWluXQogICAgc2hlbGw6IC9iaW4vYmFzaAogICAgbG9ja19wYXNzd2Q6IGZhbHNlCgojIEFxdcOtIGNlbnRyYWxpemFtb3MgZGUgZm9ybWEgbGltcGlhIGVsIGNhbWJpbyBkZSBjb250cmFzZcOxYXMgcGFyYSBhbWJvcyB1c3VhcmlvcwpjaHBhc3N3ZDoKICBsaXN0OiB8CiAgICB1YnVudHU6UHdkMTIzIQogICAgbGFib3JhdG9yaW86JDYkUmxQR1l1cTNyMi9lNk80TSRrMmljci4yUlhONzVxUWpuV0gvdlRJQnRSbzhhNHlKLmNFcHRqMTM3aXlJLkIwaXBHSjVJT3d2NUFoVzMzNGtoLjlDdzl1QXd0YVQ5TmpnZUtQdGVjMQogIGV4cGlyZTogRmFsc2UKCnJ1bmNtZDoKICAtIGFwdC1nZXQgdXBkYXRlCiAgLSBhcHQtZ2V0IGluc3RhbGwgLXkgaGFwcm94eQogIC0gWyBzeXN0ZW1jdGwsIHJlc3RhcnQsIGhhcHJveHkgXQ==
```
  5. Completar la creacion de la maquina virtual
  6. Apagar la maquina virtual y luego ir a editar configuracion para cambiar la red para que use NAT