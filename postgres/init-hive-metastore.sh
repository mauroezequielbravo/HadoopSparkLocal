#!/bin/bash
set -e

# Script de inicialización para PostgreSQL
# Crea la base de datos y el usuario para el Metastore de Hive

echo "==========================================="
echo "  Inicializando base de datos para Hive"
echo "==========================================="

# Crear usuario y base de datos para Hive
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Crear usuario para Hive si no existe
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'hive') THEN
            CREATE USER hive WITH PASSWORD 'hivepassword';
        END IF;
    END
    \$\$;

    -- Crear base de datos para el Metastore si no existe
    SELECT 'CREATE DATABASE metastore OWNER hive'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'metastore')\gexec

    -- Otorgar privilegios
    GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;

    -- Conectarse a la base de datos metastore y otorgar privilegios en el schema
    \c metastore
    GRANT ALL PRIVILEGES ON SCHEMA public TO hive;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hive;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hive;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO hive;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO hive;

EOSQL

echo "✓ Base de datos 'metastore' y usuario 'hive' creados correctamente"
echo "==========================================="
