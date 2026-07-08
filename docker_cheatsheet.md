# 🐳 Docker & Docker Compose Cheat Sheet

Referencia rápida de comandos esenciales para la gestión de contenedores, imágenes, volúmenes y orquestación local.

---

## 🚀 1. Ciclo de Vida del Contenedor

| Comando | Descripción |
| :--- | :--- |
| `docker run -d --name <nombre> -p <puerto_host>:<puerto_container> <imagen>` | Crea y arranca un contenedor en segundo plano (*detached*). |
| `docker ps` | Lista los contenedores activos. |
| `docker ps -a` | Lista todos los contenedores (activos e inactivos). |
| `docker start <nombre_o_id>` | Inicia un contenedor detenido. |
| `docker stop <nombre_o_id>` | Detiene un contenedor de forma segura (`SIGTERM`). |
| `docker restart <nombre_o_id>` | Reinicia un contenedor. |
| `docker rm <nombre_o_id>` | Elimina un contenedor detenido. |
| `docker rm -f <nombre_o_id>` | Fuerza la eliminación de un contenedor activo (`SIGKILL`). |

---

## 🔍 2. Diagnóstico y Depuración

| Comando | Descripción |
| :--- | :--- |
| `docker logs <nombre_o_id>` | Muestra la bitácora/logs de un contenedor. |
| `docker logs -f <nombre_o_id>` | Sigue los logs en tiempo real (*tail -f*). |
| `docker exec -it <nombre_o_id> /bin/bash` | Abre una terminal interactiva dentro del contenedor. |
| `docker top <nombre_o_id>` | Muestra los procesos internos del contenedor. |
| `docker stats` | Monitor de uso de CPU, Memoria y Red en tiempo real. |
| `docker inspect <nombre_o_id>` | Devuelve información técnica detallada en formato JSON. |
| `docker port <nombre_o_id>` | Muestra los puertos públicos mapeados del contenedor. |

---

## 📦 3. Gestión de Imágenes

| Comando | Descripción |
| :--- | :--- |
| `docker pull <imagen>:<tag>` | Descarga una imagen desde Docker Hub (por defecto `:latest`). |
| `docker images` | Lista todas las imágenes almacenadas localmente. |
| `docker build -t <nombre_imagen>:<tag> .` | Construye una imagen a partir de un `Dockerfile` local. |
| `docker rmi <imagen_id>` | Elimina una imagen local. |
| `docker history <nombre_imagen>` | Muestra las capas que componen una imagen. |

---

## 💾 4. Volúmenes y Redes

| Comando | Descripción |
| :--- | :--- |
| `docker volume ls` | Lista todos los volúmenes locales. |
| `docker volume create <nombre>` | Crea un volumen de datos persistente. |
| `docker volume rm <nombre>` | Elimina un volumen que no esté en uso. |
| `docker network ls` | Lista las redes disponibles. |
| `docker network create <nombre>` | Crea una red (por defecto tipo `bridge`). |

---

## 🐙 5. Docker Compose (Orquestación Local)

> *Nota: En versiones actuales usa `docker compose <comando>`. En versiones antiguas se usa con guion: `docker-compose <comando>`.*

| Comando | Descripción |
| :--- | :--- |
| `docker compose up -d` | Levanta y arranca todos los servicios definidos en segundo plano. |
| `docker compose up -d --build` | Fuerza la reconstrucción de imágenes antes de levantar. |
| `docker compose ps` | Lista el estado de los contenedores del proyecto actual. |
| `docker compose logs -f` | Muestra y sigue los logs de todos los servicios simultáneamente. |
| `docker compose logs -f <servicio>` | Sigue los logs de un único servicio específico (ej: `db`). |
| `docker compose exec <servicio> <comando>` | Ejecuta un comando en un contenedor de servicio activo. |
| `docker compose run --rm <servicio> <comando>` | Levanta un contenedor temporal para un comando aislado y lo borra al terminar. |
| `docker compose stop` | Detiene los servicios sin borrar los contenedores. |
| `docker compose down` | Detiene y elimina contenedores, redes y elementos del proyecto. |
| `docker compose down -v` | Detiene, destruye todo y **borra también los volúmenes de datos**. |

---

## 🧹 6. Limpieza del Sistema (Mantenimiento)

| Comando | Descripción |
| :--- | :--- |
| `docker system prune` | Elimina contenedores detenidos, redes sin usar e imágenes huérfanas. |
| `docker volume prune` | Elimina todos los volúmenes locales que no estén asignados a ningún contenedor. |
| `docker system prune -a --volumes` | **Limpieza Total:** Borra todo lo que no esté en uso activo (imágenes, contenedores, redes y volúmenes). |