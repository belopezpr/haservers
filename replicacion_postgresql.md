# Configuración de PostgreSQL con Streaming Replication en Ubuntu Noble

1. Instalación en ambas máquinas
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
```

2. Configuración del servidor primario
Editar /etc/postgresql/17/main/postgresql.conf:
```
listen_addresses = '*'
wal_level = replica
max_wal_senders = 5
wal_keep_size = 64MB

```

Editar /etc/postgresql/17/main/pg_hba.conf:
```
host replication replicator 192.168.1.20/32 md5
```
(Reemplaza 192.168.1.20 con la IP del servidor secundario).

Crear usuario de replicación:
```
sudo -u postgres psql
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'tu_password';
```

Reiniciar PostgreSQL:
`sudo systemctl restart postgresql`

3. Inicialización del servidor secundario

Detener PostgreSQL:
`sudo systemctl stop postgresql`

Copiar base desde el primario:
`sudo -u postgres pg_basebackup -h 192.168.1.10 -D /var/lib/postgresql/17/main -U replicator -P -R`
(Reemplaza 192.168.1.10 con la IP del primario).

4. Ajustes en el secundario

Verificar que postgresql.conf tenga:
`primary_conninfo = 'host=192.168.1.10 port=5432 user=replicator password=tu_password application_name=replica1'`

Iniciar PostgreSQL:
`sudo systemctl start postgresql`

5. Verificación de replicación

En el primario:
`sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"`

En el secundario:
`sudo -u postgres psql -c "SELECT pg_is_in_recovery();"`
Debe devolver t (true).

6. Scripts útiles

    Promover secundario:

```bash

sudo -u postgres pg_ctlcluster 17 main promote
```
    Estado de replicación:

```bash

sudo -u postgres psql -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"
```

