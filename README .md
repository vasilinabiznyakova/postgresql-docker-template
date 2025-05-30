# 🚀 PostgreSQL Database Initialization Guide

This project sets up a **PostgreSQL** instance with automatic database initialization using `docker-compose` and an `init.sql` script.

---

## 📚 Table of Contents

* [📦 Project Structure](#-project-structure)
* [⚙️ Environment Configuration](#️-environment-configuration)
* [🚀 How to Start the Database](#-how-to-start-the-database)
* [🛠️ Common Commands](#️-common-commands)
* [⚠️ Important Notes](#️-important-notes)
* [🔍 Verifying the Database](#-verifying-the-database)
* [🐞 Troubleshooting](#-troubleshooting)

---

## 📦 Project Structure

```plaintext
pg-docker/
├── certs/                 # SSL certificates for secure PostgreSQL connections
│   ├── server.crt
│   └── server.key
├── data/                   # PostgreSQL data directory (Docker volume)
├── .env                     # Environment variables (DB name, user, password, etc.)
├── docker-compose.yml       # Docker Compose configuration
├── entrypoint.sh             # Launch and initialization script
├── init.sql                  # SQL script to initialize the database
├── README.md                 # This documentation file
```

---

## ⚙️ Environment Configuration

Create a `.env` file in the `pg-docker` directory with the following variables:

```dotenv
POSTGRES_DB=mydb
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
POSTGRES_PORT=5432
```

> 📌 **Note**: These variables are used by `docker-compose` and `entrypoint.sh`.

---

## 🚀 How to Start the Database

Follow these steps:

```bash
# 📁 Move to the project directory
cd pg-docker

# 🔧 Make sure entrypoint.sh is executable
chmod +x entrypoint.sh

# 🚀 Run the entrypoint script to start the database and initialize it
./entrypoint.sh
```

### What happens:

* A `./data/` directory is created if it doesn't exist (for persistent PostgreSQL data).
* Docker Compose starts the PostgreSQL container.
* If `./data/` is empty (first run), PostgreSQL automatically executes `init.sql` to create tables and prefill initial data (e.g., periods like `24h`, `7d`, `30d`).
* The `pg_hba.conf` is updated to allow external access.
* SSL certificates are applied for secure connections.

---

## 🛠️ Common Commands

| Command                                                  | Description                                                                        |
| -------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `./entrypoint.sh`                                        | 🚀 Start the database and initialize it with `init.sql` (first run only).          |
| `docker-compose down`                                    | 🛑 Stop and remove the PostgreSQL container.                                       |
| `rm -rf ./data/*`                                        | ⚠️ Completely remove all database data (reset database).                           |
| `docker exec -it secure_postgres psql -U myuser -d mydb` | 🔍 Open a `psql` shell inside the running container to interact with the database. |
| `docker-compose logs -f`                                 | 📜 View live logs from the PostgreSQL container.                                   |
| `docker-compose restart`                                 | ♻️ Restart the PostgreSQL container without removing data.                         |
| `docker ps`                                              | 🖥️ List running Docker containers.                                                |
| `docker volume ls`                                       | 📦 List Docker volumes (to verify the database volume).                            |

---

## ⚠️ Important Notes

* **First Run Only**:
  `init.sql` will only be executed **if** the `./data/` directory is **empty**.
  If the database is already initialized, `init.sql` will not run again.

* **Resetting the Database**:
  To reset the database and rerun `init.sql`:

```bash
# Stop the container
docker-compose down

# ⚠️ WARNING: This will delete ALL database data!
rm -rf ./data/*

# Restart
./entrypoint.sh
```

* **SSL Connections**:
  The database uses the certificates provided in `certs/` to enable SSL/TLS connections.

---

## 🔍 Verifying the Database

You can connect to the running PostgreSQL container:

```bash
docker exec -it secure_postgres psql -U myuser -d mydb
```

Inside `psql`, check the tables and initial data:

```sql
\dt   -- List all tables
SELECT * FROM periods;  -- Check if initial periods are inserted
```

---

## 🐞 Troubleshooting

| Problem                                       | Solution                                                                                                                  |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `port 5432 already in use`                    | Make sure no other PostgreSQL server is running locally or change the `POSTGRES_PORT` in `.env` and `docker-compose.yml`. |
| `psql: FATAL: password authentication failed` | Check if the correct user/password is set in `.env`.                                                                      |
| `permission denied on ./data`                 | Ensure the Docker process has permissions on the `./data/` directory (`chmod 700 ./data`).                                |
| `init.sql did not run`                        | Ensure `./data/` is **empty** before first run — it only runs once.                                                       |
| `pg_hba.conf not updated`                     | Make sure the `entrypoint.sh` script has permission to modify files inside `./data/`.                                     |

---

# ✅ You’re ready to work with your PostgreSQL database!

---



<!-- 
# Command to generate self-signed certificate and key

openssl req -new -x509 -days 365 -nodes \
  -text -out certs/server.crt \
  -keyout certs/server.key \
  -subj "//CN=localhost"


# restrict access to server.key for all except server
chmod 600 certs/server.key


# check if previous rule was applied 
ls -l certs/server.key





