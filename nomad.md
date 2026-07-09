# Nomad

HashiCorp Nomad es un orquestador de aplicaciones sencillo, flexible y ligero. Su función principal es permitirte desplegar y gestionar contenedores y aplicaciones no contenedorizadas a gran escala a lo largo de múltiples servidores.

A diferencia de otras herramientas que se enfocan exclusivamente en contenedores, Nomad es conocido por su versatilidad.

## ¿Cómo funciona? (Conceptos Clave)

Nomad funciona bajo una arquitectura de Servidores (que toman las decisiones y planifican) y Clientes (los nodos de trabajo que ejecutan las tareas).

Trabajo (Job): Es el archivo de configuración (escrito en HCL, el lenguaje de HashiCorp) donde defines qué quieres ejecutar, cuántas instancias necesitas y qué recursos requiere.

Grupo (Group): Un conjunto de tareas que deben ejecutarse juntas en la misma máquina.

Tarea (Task): La unidad mínima de trabajo (por ejemplo, un contenedor Docker, un script de Python o un binario de Java).

## Características Principales

Multidriver (No solo Docker): Esta es su mayor ventaja. Puede orquestar contenedores Docker, pero también ejecutables binarios directos, funciones de Java (JARs), o comandos de sistema mediante diferentes "drivers" de ejecución.

Simplicidad y ligereza: Se distribuye como un único binario optimizado. Consume una fracción de los recursos (memoria y CPU) que requieren otros orquestadores complejos, lo que lo hace ideal tanto para grandes centros de datos como para servidores modestos o entornos de desarrollo.

Ecosistema HashiCorp: Se integra de forma nativa con Consul (para el descubrimiento de servicios y malla de red) y Vault (para la gestión segura de secretos y contraseñas).

Escalabilidad: Está diseñado para escalar a miles de nodos globalmente de manera muy eficiente.

## Arquitectura básica de Nomad

Nomad funciona bajo un modelo muy limpio de servidores y clientes, comunicándose de manera eficiente sin requerir bases de datos externas complejas:

Nomad Servers: Son el "cerebro" del clúster. Se encargan de recibir los trabajos (jobs), gestionar el estado de la infraestructura, tomar decisiones de programación (dónde ejecutar qué) y replicar los datos entre sí mediante el protocolo Raft para alta disponibilidad.

Nomad Clients: Son los nodos "obreros". Corren en los servidores reales donde se ejecutan las aplicaciones. Se comunican mediante llamadas RPC con los servidores para recibir asignaciones y reportar el estado de los recursos.

Integración nativa: Se conecta directamente con Consul para el descubrimiento de servicios y Vault para la gestión de secretos, formando el ecosistema clásico de HashiCorp.