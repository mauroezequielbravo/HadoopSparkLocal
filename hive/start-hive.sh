#!/bin/bash

echo "==========================================="
echo "  Iniciando Apache Hive"
echo "==========================================="

# Configuración de variables de entorno
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive
export HADOOP_CONF_DIR=/opt/hadoop-conf

# Función para esperar a que un servicio esté disponible
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    local max_attempts=60
    local attempt=1

    echo "Esperando a que $service_name esté disponible en $host:$port..."
    
    while ! nc -z $host $port; do
        if [ $attempt -eq $max_attempts ]; then
            echo "ERROR: $service_name no está disponible después de $max_attempts intentos"
            exit 1
        fi
        echo "Intento $attempt/$max_attempts: Esperando a $service_name..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "✓ $service_name está disponible"
}

# Esperar a que PostgreSQL esté listo
wait_for_service postgres 5432 "PostgreSQL"

# Esperar a que Hadoop HDFS esté listo
wait_for_service hadoop-master 9870 "Hadoop NameNode"

echo "==========================================="
echo "  Verificando conectividad con HDFS"
echo "==========================================="

# Verificar que podemos conectarnos a HDFS
max_attempts=15
attempt=1
while ! $HADOOP_HOME/bin/hdfs dfs -ls / > /dev/null 2>&1; do
    if [ $attempt -eq $max_attempts ]; then
        echo "⚠ Advertencia: No se pudo verificar HDFS, continuando de todos modos..."
        break
    fi
    echo "Intento $attempt/$max_attempts: Esperando a que HDFS esté completamente operativo..."
    sleep 3
    attempt=$((attempt + 1))
done

echo "✓ Conectividad con HDFS verificada"

echo "==========================================="
echo "  Creando directorios en HDFS"
echo "==========================================="

# Crear directorios necesarios en HDFS
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse 2>/dev/null || true
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp/hive 2>/dev/null || true
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /user/hive/warehouse 2>/dev/null || true
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /tmp/hive 2>/dev/null || true

echo "✓ Directorios de Hive configurados en HDFS"

# Determinar qué servicio iniciar según la variable de entorno
if [ "$HIVE_SERVICE" == "metastore" ]; then
    echo "==========================================="
    echo "  Inicializando esquema del Metastore"
    echo "==========================================="
    
    # Inicializar el esquema de la base de datos (solo si es necesario)
    # Esto creará las tablas necesarias en PostgreSQL
    $HIVE_HOME/bin/schematool -dbType postgres -initSchema || echo "Esquema ya existe o error en inicialización (continuando...)"
    
    echo "==========================================="
    echo "  Iniciando Hive Metastore Service"
    echo "==========================================="
    
    # Iniciar Metastore en primer plano
    $HIVE_HOME/bin/hive --service metastore

elif [ "$HIVE_SERVICE" == "hiveserver2" ]; then
    echo "==========================================="
    echo "  Esperando a que Metastore esté listo"
    echo "==========================================="
    
    # Esperar a que el Metastore esté disponible
    wait_for_service hive-metastore 9083 "Hive Metastore"
    
    echo "==========================================="
    echo "  Iniciando HiveServer2"
    echo "==========================================="
    echo ""
    echo "HiveServer2 estará disponible en:"
    echo "  - JDBC: jdbc:hive2://localhost:10000"
    echo "  - Web UI: http://localhost:10002"
    echo ""
    echo "Para conectarte con Beeline:"
    echo "  beeline -u jdbc:hive2://localhost:10000"
    echo ""
    
    # Iniciar HiveServer2 en primer plano
    $HIVE_HOME/bin/hive --service hiveserver2

else
    echo "ERROR: Variable HIVE_SERVICE no configurada"
    echo "Debe ser 'metastore' o 'hiveserver2'"
    exit 1
fi
