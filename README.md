# 🗄️ Microsoft SQL Server en Docker (Windows)

Despliegue de **Microsoft SQL Server 2022** en contenedor Docker, con **persistencia de datos** y **script de inicialización** para crear una base de datos y un usuario de aplicación.

---

## 📦 Contenido del proyecto

```
mssql-docker/
├─ docker-compose.yml
├─ .env              # (crear desde .env.example)
├─ init/
│  └─ 01-init.sql
└─ scripts/
   └─ connect.ps1
```

---

## ✅ Requisitos

- **Windows 10/11** con **Docker Desktop** (WSL2 backend recomendado).
- 2 GB de RAM libres para el contenedor SQL Server.
- Conectividad a Docker Hub. Si usas proxy corporativo, consulta la sección de *Troubleshooting*.

---

## ⚙️ Variables (.env)

Crea un fichero `.env` en la raíz del proyecto (o copia desde `.env.example`) con este contenido:

```ini
SA_PASSWORD=Str0ngP@ssw0rd!2025
MSSQL_DATABASE=mi_base_datos
MSSQL_USER=usuario_app
MSSQL_PASSWORD=Usu@rioP4ss2025!
MSSQL_PORT=1433
```

> **Notas:**  
> - `SA_PASSWORD` debe cumplir la política de complejidad (mayúsculas, minúsculas, número y símbolo, 8+).  
> - Cambia todas las contraseñas antes de uso real.

---

## 🧩 docker-compose.yml

Este `docker-compose.yml` levanta el servidor y ejecuta un **servicio de inicialización** que crea la BBDD y el usuario:

```yaml
services:
  sqlserver:
    image: docker.io/mcr.microsoft.com/mssql/server:2022-latest
    container_name: mssql_server
    restart: unless-stopped
    ports:
      - "${MSSQL_PORT}:1433"
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=${SA_PASSWORD}
    volumes:
      - mssql_data:/var/opt/mssql
      - ./init:/init:ro
    # If you're on Windows ARM, uncomment next line to force emulation
    # platform: linux/amd64

  db-init:
    image: docker.io/mcr.microsoft.com/mssql-tools
    container_name: mssql_db_init
    depends_on:
      - sqlserver
    restart: "no"
    volumes:
      - ./init:/init:ro
    environment:
      - ACCEPT_EULA=Y
    entrypoint: ["/bin/bash","-c",
      "for i in {1..60}; do /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -Q 'SELECT 1' && break || sleep 2; done;        /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -v DBNAME=${MSSQL_DATABASE} APPUSER=${MSSQL_USER} APPPASS=${MSSQL_PASSWORD} -i /init/01-init.sql"
    ]

volumes:
  mssql_data:
```

---

## ▶️ Puesta en marcha

1. **Descarga los archivos** de este repositorio local:
   - `docker-compose.yml`
   - `.env.example`
   - `init/01-init.sql`
   - `scripts/connect.ps1`

2. **Crea `.env`** a partir de `.env.example` y ajusta contraseñas/puertos.

3. **Inicia los servicios** (en PowerShell/CMD dentro de la carpeta):
   ```powershell
   docker compose up -d
   ```

4. **Comprueba contenedores**:
   ```powershell
   docker ps
   ```

5. **Ver logs de SQL Server (opcional)**:
   ```powershell
   docker logs -f mssql_server
   ```

---

## 🔌 Conexión a la base de datos

### Opción A) Línea de comandos dentro del contenedor
```powershell
docker exec -it mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "TU_SA_PASSWORD"
```
> Ejemplo rápido:
```sql
SELECT @@VERSION;
GO
```

### Opción B) Con el script de ayuda (PowerShell)
```powershell
.\scripts\connect.ps1
```
El script lee `.env` y abre `sqlcmd` directamente.

### Opción C) Herramienta gráfica
- **Azure Data Studio** o **SQL Server Management Studio (SSMS)**  
  - **Servidor**: `localhost,1433`  
  - **Usuario**: `SA` (o `MSSQL_USER`)  
  - **Contraseña**: la definida en `.env`

---

## 🗄️ Persistencia y backups

- Los datos se guardan en el volumen **`mssql_data`**.  
- Backups:
  ```powershell
  docker exec -i mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "TU_SA_PASSWORD" -Q "BACKUP DATABASE [mi_base_datos] TO DISK = N'/var/opt/mssql/backup/mi_base_datos.bak' WITH INIT"
  ```
  *(crea primero `/var/opt/mssql/backup` dentro del contenedor si no existe).*

---

## 🧹 Gestión rápida

- **Parar**: `docker compose down`  
- **Parar y borrar datos**: `docker compose down -v`  ⚠️ *(elimina la BBDD)*  
- **Actualizar imagen**: `docker compose pull && docker compose up -d`

---

## 🛠️ Troubleshooting

- **TLS/x509 al hacer pull**: fuerza Docker Hub o ajusta proxy/CA corporativa. En `docker-compose.yml` ya usamos rutas `docker.io/...`.  
- **Política de contraseñas**: cambia `SA_PASSWORD` por una más fuerte si el contenedor se reinicia en bucle.  
- **Puerto ocupado (1433)**: cambia `MSSQL_PORT` en `.env`.  
- **ARM (Windows on ARM)**: descomenta `platform: linux/amd64` en `docker-compose.yml`.

---

¡Listo! Con esto puedes levantar **SQL Server 2022 en Docker** con **persistencia** e **inicialización automática**, y conectarte por CLI o GUI.
