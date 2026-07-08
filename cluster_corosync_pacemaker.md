# Arquitecturas de Alta Disponibilidad y Escalabilidad: Clusters y Sistemas Distribuidos

Este documento técnico define los conceptos fundamentales, diferencias y mecanismos de coordinación esenciales en arquitecturas multi-nodo, abarcando desde la organización de servidores hasta los protocolos de consenso y tolerancia a fallos.

---

## 1. Cluster vs. Sistema Distribuido

Aunque ambos conceptos involucran múltiples computadoras trabajando en red, difieren profundamente en su acoplamiento, homogeneidad y objetivos de diseño.

### ¿Qué es un Cluster?
Un **Cluster** es un conjunto de computadoras independientes (llamadas **nodos**) conectadas entre sí mediante una red de alta velocidad y baja latencia, las cuales **actúan hacia el exterior como un único sistema integrado**.

* **Ubicación:** Centralizada (usualmente en el mismo rack o centro de datos).
* **Homogeneidad:** Alta. Los nodos suelen compartir el mismo hardware, sistema operativo y configuración.
* **Acoplamiento:** Fuerte. Comparten un almacenamiento común (como una SAN/NAS) o utilizan redes dedicadas (como InfiniBand) para sincronizar su estado en milisegundos.
* **Objetivo principal:** Alta disponibilidad (HA) para mitigar puntos únicos de fallo (SPOF) o alto rendimiento (HPC).

### ¿Qué es un Sistema Distribuido?
Un **Sistema Distribuido** es una colección de computadoras independientes que colaboran para lograr un objetivo común, pero **cada nodo mantiene su propia autonomía, memoria y rol específico**, presentándose ante el usuario como un servicio unificado.

* **Ubicación:** Dispersa. Los nodos pueden estar distribuidos geográficamente en diferentes regiones o continentes.
* **Heterogeneidad:** Alta. Los nodos pueden ejecutar distintos sistemas operativos, arquitecturas de hardware y tecnologías de red.
* **Acoplamiento:** Débil. La comunicación se realiza estrictamente mediante el paso de mensajes a través de redes WAN o Internet.
* **Objetivo principal:** Escalabilidad global, compartición de recursos y resiliencia ante catástrofes geográficas (ej. redes de entrega de contenido (CDN), arquitecturas de microservicios o plataformas Blockchain).

---

## 2. Conceptos Clave de Operación y Consenso

Para garantizar la consistencia de los datos y evitar el caos operativo, estos sistemas implementan reglas estrictas de coordinación.

### Quorum (Mecanismo de Consenso)
El **Quorum** es el número mínimo de votos (nodos operativos y comunicados) que se requieren dentro de un sistema multi-nodo para tomar una decisión válida, realizar escrituras de datos o continuar operando legalmente.

* **El Problema del Split-Brain (Cerebro Dividido):** Si un cluster de 4 nodos sufre una falla de red interna que lo divide en dos partes aisladas de 2 nodos cada una, ambas mitades podrían intentar asumir el control, corrompiendo el almacenamiento compartido al escribir datos contradictorios.
* **Solución mediante Quorum:** Se establece una regla de mayoría estricta:
  $$\text{Quorum} = \left\lfloor \frac{N}{2} \right\rfloor + 1$$
  Donde $N$ es el número total de nodos. En un cluster de 3 nodos, el quorum es 2. Si la red se parte (un nodo aislado y dos comunicados), la partición con 2 nodos alcanza el quorum y sigue operando; el nodo aislado se bloquea automáticamente al no alcanzar la mayoría.
* **Configuración Impar:** Es por esto que los clusters basados en quórum (como los respaldados por *Corosync/Pacemaker*, *ZooKeeper* o *etcd*) se configuran típicamente con un **número impar de nodos (3, 5, 7)** para evitar empates técnicos en las votaciones.

### Estados de Disponibilidad: Activo y Pasivo

Dependiendo de cómo se distribuyan las cargas de trabajo y los datos, los nodos adoptan diferentes roles operativos:

#### 1. Arquitectura Activo / Pasivo (Failover)
En este modelo (también conocido como *Master/Slave* o *Primary/Standby*), los nodos se dividen las responsabilidades de disponibilidad:

* **Nodo Activo:** Procesa todas las solicitudes de los clientes, ejecuta la lógica de negocio y realiza las operaciones de lectura y escritura en caliente.
* **Nodo Pasivo:** Permanece en estado de reposo (*standby*). Su única tarea es replicar los datos del nodo activo (ya sea de forma síncrona o asíncrona) para mantenerse actualizado. No atiende tráfico de usuarios directamente.
* **Mecanismo de Failover:** Los nodos intercambian pulsos de red constantemente (*heartbeats*). Si el nodo pasivo deja de recibir el pulso del activo durante un umbral de tiempo determinado, asume que ha fallado y se "promueve" automáticamente a estado Activo para mantener la continuidad del servicio.

#### 2. Arquitectura Activo / Activo
En este modelo, **todos los nodos del sistema procesan solicitudes simultáneamente**.

* Un balanceador de carga frontal distribuye las peticiones entrantes entre todos los nodos disponibles.
* **Ventajas:** Aprovechamiento óptimo del hardware y mayor capacidad de procesamiento inmediato (escalabilidad horizontal).
* **Desafío Técnico:** Requiere mecanismos complejos de bloqueo distribuido y sincronización en tiempo real para evitar condiciones de carrera (*race conditions*) y asegurar que todos los nodos vean exactamente los mismos datos al mismo tiempo.

---

## 3. Matriz Comparativa Resumida

| Criterio | Cluster (Computación en Grupo) | Sistema Distribuido |
| :--- | :--- | :--- |
| **Latencia de Red** | Extremadamente baja (Microsegundos). | Variable / Alta (Milisegundos). |
| **Ubicación Física** | Centralizada (Mismo entorno local). | Geográficamente dispersa (Multi-región). |
| **Almacenamiento** | Frecuentemente compartido (SAN/NAS). | Distribuido / Replicado por red. |
| **Gestión de Estado** | Monitoreo centralizado o por Quorum local. | Protocolos de consenso global (Raft, Paxos). |
| **Transparencia** | El usuario lo percibe como una sola máquina virtual. | El usuario percibe un servicio único, pero distribuido. |


# PRACTICA: Cluster de HAProxy (2 Nodos)

Asumamos que tus dos máquinas virtuales tienen estas IPs (cámbialas por las tuyas):

    Nodo 1: 192.168.1.10 (hostname: haproxy1)

    Nodo 2: 192.168.1.11 (hostname: haproxy2)

    IP Virtual (VIP): 192.168.1.100 (Esta IP no debe estar asignada estáticamente a ninguna máquina; debe estar libre en tu red).

1. Comandos de Instalación (En AMBOS nodos)
```
# Actualizar sistema e instalar Pacemaker, Corosync y la herramienta de gestión PCS
sudo apt update && sudo apt install -y pacemaker corosync pcs resource-agents

# Asignar una contraseña al usuario del sistema 'hacluster' (usa la misma en ambos)
echo "hacluster:PasswordDemo123" | sudo chpasswd

# Habilitar e iniciar el demonio de configuración
sudo systemctl enable --now pcsd
```

2. Configuración del Cluster (Solo en haproxy1)

Ejecuta estos comandos secuencialmente para entrelazar las dos máquinas:
```
# 1. Autenticar los nodos entre sí
sudo pcs host auth haproxy1 haproxy2 -u hacluster -p PasswordDemo123

# 2. Crear el cluster y arrancar Corosync/Pacemaker en ambos lados
sudo pcs cluster setup cluster_proxy haproxy1 haproxy2 --start --enable

# 3. Configuración para Laboratorio (Desactivar STONITH/Fencing y permitir clusters de 2 nodos)
sudo pcs property set stonith-enabled=false
sudo pcs property set no-quorum-policy=ignore

# 4. Crear el recurso de la IP Virtual (VIP)
sudo pcs resource create VirtualIP ocf:heartbeat:IPaddr2 ip=192.168.1.100 cidr_netmask=24 op monitor interval=10s

# 5. Crear el recurso de HAProxy (monitorea el servicio de systemd)
sudo pcs resource create ProxyService systemd:haproxy op monitor interval=10s

# 6. RESTRICCIÓN DE COLOCACIÓN: Forzar a que HAProxy corra en el mismo nodo que la VIP
sudo pcs constraint colocation add ProxyService with VirtualIP score=INFINITY

# 7. RESTRICCIÓN DE ORDEN: Primero se levanta la IP, luego el servicio de HAProxy
sudo pcs constraint order VirtualIP then ProxyService
```

3. Comandos de Prueba para HAProxy

Para verificar que el cluster responde y conmuta correctamente:

    Ver el estado en tiempo real:
`watch -n 1 pcs status`
Ahí verás qué nodo tiene actualmente asignada la VirtualIP y el ProxyService.

Prueba de Failover Manual (Simular mantenimiento):
Si pasas el nodo activo a modo "standby", verás cómo los recursos saltan instantáneamente al segundo nodo.
`sudo pcs node standby haproxy1`

Para reactivarlo y dejarlo listo para recibir carga de nuevo:
`sudo pcs node unstandby haproxy1`

