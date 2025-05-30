#!/bin/bash
cd "$(dirname "$0")"

# 📦 Load .env variables for local use (DB name, user, port, etc)
set -a
source .env
set +a

# 📁 Ensure ./data exists
if [ ! -d "./data" ]; then
  echo "📁 Creating ./data directory..."
  mkdir -p ./data
fi

# ⚠️ Warn if not empty
if [ "$(ls -A ./data)" ]; then
  echo "⚠️  ./data is NOT empty. Existing database may be used."
else
  echo "✅ ./data is empty. Fresh init expected."
fi

# 🚀 Start PostgreSQL
echo "🚀 Starting PostgreSQL with Docker Compose..."
docker-compose up -d

# ⏳ Wait until pg_hba.conf appears (up to 20 seconds)
echo "⌛ Waiting for ./data/pg_hba.conf to be created..."
for i in {1..20}; do
  if [ -f "./data/pg_hba.conf" ]; then
    echo "✅ Found pg_hba.conf after $i second(s)"
    break
  fi
  sleep 1
done

# ✍️ Append external access rules to pg_hba.conf
HBA_FILE="./data/pg_hba.conf"
if [ -f "$HBA_FILE" ]; then
  echo "🔧 Updating pg_hba.conf..."
  cp "$HBA_FILE" "$HBA_FILE.bak"

  grep -q "0.0.0.0/0" "$HBA_FILE" || echo "host    all    all    0.0.0.0/0    md5" >> "$HBA_FILE"
  grep -q "172.19.0.1/32" "$HBA_FILE" || echo "host    all    all    172.19.0.1/32    md5" >> "$HBA_FILE"

  echo "♻️ Waiting for PostgreSQL to become ready to reload config..."

  for i in {1..10}; do
    if docker exec -u postgres secure_postgres psql -d "$POSTGRES_DB" -U "$POSTGRES_USER" -c "SELECT 1;" >/dev/null 2>&1; then
      docker exec -u postgres secure_postgres psql -d "$POSTGRES_DB" -U "$POSTGRES_USER" -c "SELECT pg_reload_conf();"
      echo "✅ pg_hba.conf reloaded successfully"
      break
    fi
    echo "⏳ PostgreSQL not ready yet... waiting ($i/10)"
    sleep 2
  done
else
  echo "❌ pg_hba.conf not found after waiting. Cannot apply access rules."
fi
