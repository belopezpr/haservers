# Replicar Filesystem con DRBD
1. Instalar DRBD
```
sudo apt install drbd-utils
sudo apt install resource-agents-base resource-agents-extra resource-agents-common -y

```
* nota instalar el modulo del kernel no viene predefinido por ser una imagen minima la que se usa de ubuntu
```
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:linbit/linbit-drbd9-stack
sudo apt update
sudo apt install -y drbd-dkms linux-headers-generic
sudo modprobe drbd
```

1. Acceder en el directorio de configuración de DRBD con el siguiente comando:
cd /etc/drbd.d/
1. Crear un archivo de configuración (/etc/drbd.d/r0.res) que defina el recurso, la
partición a replicar y los nodos involucrados. Usar el editor de texto nano para crear
y editar el archivo de configuración de la siguiente manera:
sudo nano r0.res
Esto abrirá un archivo vacío en el editor.
1. Colocar el siguiente código en el archivo, asegurándose de usar las IPs correctas de
los nodos (192.168.10.101 y 192.168.10.102) y la partición del nuevo disco
(/dev/sdb1)

```
resource r0 {
    on nodo1 {
        device /dev/drbd0;
        disk /dev/sdb1;
        address 192.168.122.144:7788;
        meta-disk internal;
    }
    on nodo2 {
        device /dev/drbd0;
        disk /dev/sdb1;
        address 192.168.122.145:7788;
        meta-disk internal;
    }
    net {
        protocol C;
    }
}
```

5. Acceder en el directorio de configuración de DRBD con el siguiente comando:
cd /etc/drbd.d/
6. Crear un archivo de configuración (/etc/drbd.d/r0.res) que defina el recurso, la
partición a replicar y los nodos involucrados. Usar el editor de texto nano para crear
y editar el archivo de configuración de la siguiente manera:
sudo nano r0.res
Esto abrirá un archivo vacío en el editor.
7. Colocar el siguiente código en el archivo, asegurándose de usar las IPs correctas de
los nodos (192.168.10.101 y 192.168.10.102) y la partición del nuevo disco
(/dev/sdb1):
Asegurarse que la indentación (los espacios) sea correcta, ya que YAML es muy
sensible a esto. Al usar nano, presiona Ctrl + O para guardar y luego Ctrl + X para salir.
8. Repetir estos mismos pasos en el segundo nodo.
9. En ambos nodos, inicializar el metadato del DRBD con:
`sudo drbdadm create-md r0`

10.  En ambos nodos, levantar el recurso con: 
`sudo drbdadm up r0`
11.   En un solo nodo, promueve la partición como primaria para iniciar la
sincronización:
`sudo drbdadm --force primary r0`

12.  En el nodo primario, crear un sistema de archivos: `sudo mkfs.ext4 /dev/drbd0`
13. Crear un directorio /mnt/ha con 
`sudo mkdir /mnt/ha`, 
montar el dispositivo con
`sudo mount /dev/drbd0 /mnt/ha`. 
Este es el punto de montaje que el clúster usará
para acceder a los datos y verificarlo con `df -h`

## Probar el failover manual:
- En el nodo primario (Primary/Secondary), crear un archivo de prueba en el punto
de montaje que se hizo antes (/mnt/ha). Por ejemplo: 
`sudo touch /mnt/ha/testfile.txt`. 
Luego, desmonta y demociona el recurso:
`sudo umount /mnt/ha`
`sudo drbdadm secondary r0`

- En el nodo secundario (Secondary/Primary), promoverlo a primario: 
`sudo drbdadm primary r0`. 
Luego, montarlo: `sudo mount /dev/drbd0 /mnt/ha`.

- Verificar que el archivo testfile.txt esté presente en /mnt/ha. Si está, significa que la replicación funcionó correctamente
