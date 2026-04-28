# 🗄️ Microsoft SQL Server en Docker (Windows)

---

## 🌐 Índice de idiomas / Language Index / Sprachindex

| | Idioma | Sección |
|---|---|---|
| 🇪🇸 | Español | [Ver en español](#-versión-en-español) |
| 🇬🇧 | English | [View in English](#-english-version) |
| 🇩🇪 | Deutsch | [Auf Deutsch lesen](#-deutsche-version) |

---

---

# 🇪🇸 Versión en Español

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
    # Si estás en Windows ARM, descomenta la siguiente línea para forzar emulación
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
      "for i in {1..60}; do /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -Q 'SELECT 1' && break || sleep 2; done;
       /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -v DBNAME=${MSSQL_DATABASE} APPUSER=${MSSQL_USER} APPPASS=${MSSQL_PASSWORD} -i /init/01-init.sql"
    ]

volumes:
  mssql_data:
```

---

## ▶️ Puesta en marcha

1. **Descarga los archivos** de este repositorio:
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
  *(Crea primero `/var/opt/mssql/backup` dentro del contenedor si no existe.)*

---

## 🧹 Gestión rápida

- **Parar**: `docker compose down`
- **Parar y borrar datos**: `docker compose down -v` ⚠️ *(elimina la BBDD)*
- **Actualizar imagen**: `docker compose pull && docker compose up -d`

---

## 🛠️ Troubleshooting

- **TLS/x509 al hacer pull**: fuerza Docker Hub o ajusta proxy/CA corporativa. En `docker-compose.yml` ya usamos rutas `docker.io/...`.
- **Política de contraseñas**: cambia `SA_PASSWORD` por una más fuerte si el contenedor se reinicia en bucle.
- **Puerto ocupado (1433)**: cambia `MSSQL_PORT` en `.env`.
- **ARM (Windows on ARM)**: descomenta `platform: linux/amd64` en `docker-compose.yml`.

---

[⬆️ Volver al índice](#-índice-de-idiomas--language-index--sprachindex)

---

---

# 🇬🇧 English Version

Deployment of **Microsoft SQL Server 2022** in a Docker container, with **data persistence** and an **initialization script** to create a database and an application user.

---

## 📦 Project Contents

```
mssql-docker/
├─ docker-compose.yml
├─ .env              # (create from .env.example)
├─ init/
│  └─ 01-init.sql
└─ scripts/
   └─ connect.ps1
```

---

## ✅ Requirements

- **Windows 10/11** with **Docker Desktop** (WSL2 backend recommended).
- 2 GB of free RAM for the SQL Server container.
- Connectivity to Docker Hub. If you use a corporate proxy, refer to the *Troubleshooting* section.

---

## ⚙️ Variables (.env)

Create a `.env` file at the project root (or copy from `.env.example`) with the following content:

```ini
SA_PASSWORD=Str0ngP@ssw0rd!2025
MSSQL_DATABASE=my_database
MSSQL_USER=app_user
MSSQL_PASSWORD=Usu@rioP4ss2025!
MSSQL_PORT=1433
```

> **Notes:**
> - `SA_PASSWORD` must meet the complexity policy (uppercase, lowercase, number and symbol, 8+ characters).
> - Change all passwords before real use.

---

## 🧩 docker-compose.yml

This `docker-compose.yml` starts the server and runs an **initialization service** that creates the database and user:

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
      "for i in {1..60}; do /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -Q 'SELECT 1' && break || sleep 2; done;
       /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -v DBNAME=${MSSQL_DATABASE} APPUSER=${MSSQL_USER} APPPASS=${MSSQL_PASSWORD} -i /init/01-init.sql"
    ]

volumes:
  mssql_data:
```

---

## ▶️ Getting Started

1. **Download the files** from this repository:
   - `docker-compose.yml`
   - `.env.example`
   - `init/01-init.sql`
   - `scripts/connect.ps1`

2. **Create `.env`** from `.env.example` and adjust passwords/ports.

3. **Start the services** (in PowerShell/CMD inside the folder):
   ```powershell
   docker compose up -d
   ```

4. **Check containers**:
   ```powershell
   docker ps
   ```

5. **View SQL Server logs (optional)**:
   ```powershell
   docker logs -f mssql_server
   ```

---

## 🔌 Connecting to the Database

### Option A) Command line inside the container
```powershell
docker exec -it mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YOUR_SA_PASSWORD"
```
> Quick example:
```sql
SELECT @@VERSION;
GO
```

### Option B) Using the helper script (PowerShell)
```powershell
.\scripts\connect.ps1
```
The script reads `.env` and opens `sqlcmd` directly.

### Option C) Graphical tool
- **Azure Data Studio** or **SQL Server Management Studio (SSMS)**
  - **Server**: `localhost,1433`
  - **User**: `SA` (or `MSSQL_USER`)
  - **Password**: as defined in `.env`

---

## 🗄️ Persistence and Backups

- Data is stored in the **`mssql_data`** volume.
- Backups:
  ```powershell
  docker exec -i mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YOUR_SA_PASSWORD" -Q "BACKUP DATABASE [my_database] TO DISK = N'/var/opt/mssql/backup/my_database.bak' WITH INIT"
  ```
  *(First create `/var/opt/mssql/backup` inside the container if it does not exist.)*

---

## 🧹 Quick Management

- **Stop**: `docker compose down`
- **Stop and delete data**: `docker compose down -v` ⚠️ *(removes the database)*
- **Update image**: `docker compose pull && docker compose up -d`

---

## 🛠️ Troubleshooting

- **TLS/x509 when pulling**: force Docker Hub or adjust proxy/corporate CA. The `docker-compose.yml` already uses `docker.io/...` paths.
- **Password policy**: change `SA_PASSWORD` to a stronger one if the container keeps restarting.
- **Port in use (1433)**: change `MSSQL_PORT` in `.env`.
- **ARM (Windows on ARM)**: uncomment `platform: linux/amd64` in `docker-compose.yml`.

---

[⬆️ Back to index](#-índice-de-idiomas--language-index--sprachindex)

---

---

# 🇩🇪 Deutsche Version

Bereitstellung von **Microsoft SQL Server 2022** in einem Docker-Container mit **Datenpersistenz** und einem **Initialisierungsskript** zum Erstellen einer Datenbank und eines Anwendungsbenutzers.

---

## 📦 Projektinhalt

```
mssql-docker/
├─ docker-compose.yml
├─ .env              # (aus .env.example erstellen)
├─ init/
│  └─ 01-init.sql
└─ scripts/
   └─ connect.ps1
```

---

## ✅ Voraussetzungen

- **Windows 10/11** mit **Docker Desktop** (WSL2-Backend empfohlen).
- 2 GB freier RAM für den SQL Server-Container.
- Verbindung zu Docker Hub. Bei Verwendung eines Unternehmens-Proxys siehe Abschnitt *Fehlerbehebung*.

---

## ⚙️ Variablen (.env)

Erstelle eine `.env`-Datei im Projektstammverzeichnis (oder kopiere aus `.env.example`) mit folgendem Inhalt:

```ini
SA_PASSWORD=Str0ngP@ssw0rd!2025
MSSQL_DATABASE=meine_datenbank
MSSQL_USER=app_benutzer
MSSQL_PASSWORD=Usu@rioP4ss2025!
MSSQL_PORT=1433
```

> **Hinweise:**
> - `SA_PASSWORD` muss die Komplexitätsrichtlinie erfüllen (Groß-, Kleinbuchstaben, Zahl und Symbol, mind. 8 Zeichen).
> - Alle Passwörter vor dem Produktionseinsatz ändern.

---

## 🧩 docker-compose.yml

Diese `docker-compose.yml` startet den Server und führt einen **Initialisierungsdienst** aus, der die Datenbank und den Benutzer erstellt:

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
    # Bei Windows ARM folgende Zeile auskommentieren, um Emulation zu erzwingen
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
      "for i in {1..60}; do /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -Q 'SELECT 1' && break || sleep 2; done;
       /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P ${SA_PASSWORD} -v DBNAME=${MSSQL_DATABASE} APPUSER=${MSSQL_USER} APPPASS=${MSSQL_PASSWORD} -i /init/01-init.sql"
    ]

volumes:
  mssql_data:
```

---

## ▶️ Inbetriebnahme

1. **Dateien herunterladen** aus diesem Repository:
   - `docker-compose.yml`
   - `.env.example`
   - `init/01-init.sql`
   - `scripts/connect.ps1`

2. **`.env` erstellen** aus `.env.example` und Passwörter/Ports anpassen.

3. **Dienste starten** (in PowerShell/CMD im Projektordner):
   ```powershell
   docker compose up -d
   ```

4. **Container überprüfen**:
   ```powershell
   docker ps
   ```

5. **SQL Server-Logs anzeigen (optional)**:
   ```powershell
   docker logs -f mssql_server
   ```

---

## 🔌 Verbindung zur Datenbank

### Option A) Befehlszeile im Container
```powershell
docker exec -it mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "DEIN_SA_PASSWORT"
```
> Schnellbeispiel:
```sql
SELECT @@VERSION;
GO
```

### Option B) Mit dem Hilfsskript (PowerShell)
```powershell
.\scripts\connect.ps1
```
Das Skript liest `.env` und öffnet `sqlcmd` direkt.

### Option C) Grafisches Werkzeug
- **Azure Data Studio** oder **SQL Server Management Studio (SSMS)**
  - **Server**: `localhost,1433`
  - **Benutzer**: `SA` (oder `MSSQL_USER`)
  - **Passwort**: wie in `.env` definiert

---

## 🗄️ Persistenz und Backups

- Daten werden im Volume **`mssql_data`** gespeichert.
- Backups:
  ```powershell
  docker exec -i mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "DEIN_SA_PASSWORT" -Q "BACKUP DATABASE [meine_datenbank] TO DISK = N'/var/opt/mssql/backup/meine_datenbank.bak' WITH INIT"
  ```
  *(Erstelle zuerst `/var/opt/mssql/backup` im Container, falls nicht vorhanden.)*

---

## 🧹 Schnellverwaltung

- **Stoppen**: `docker compose down`
- **Stoppen und Daten löschen**: `docker compose down -v` ⚠️ *(löscht die Datenbank)*
- **Image aktualisieren**: `docker compose pull && docker compose up -d`

---

## 🛠️ Fehlerbehebung

- **TLS/x509 beim Pull**: Docker Hub erzwingen oder Proxy/Unternehmens-CA anpassen. Die `docker-compose.yml` verwendet bereits `docker.io/...`-Pfade.
- **Passwortrichtlinie**: `SA_PASSWORD` durch ein stärkeres ersetzen, wenn der Container in einer Neustartschleife hängt.
- **Port belegt (1433)**: `MSSQL_PORT` in `.env` ändern.
- **ARM (Windows on ARM)**: `platform: linux/amd64` in `docker-compose.yml` auskommentieren.

---

[⬆️ Zurück zum Index](#-índice-de-idiomas--language-index--sprachindex)