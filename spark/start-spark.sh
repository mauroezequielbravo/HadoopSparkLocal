#!/bin/bash

echo "========================================="
echo "Iniciando Contenedor Spark"
echo "========================================="

# Configuración de Java
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Esperar a que Hadoop esté disponible
echo "Esperando a que Hadoop esté disponible..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if nc -z hadoop-master 9000 2>/dev/null; then
        echo "Hadoop HDFS está disponible!"
        break
    fi
    echo "Intento $((attempt+1))/$max_attempts: Esperando a Hadoop..."
    sleep 5
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "ADVERTENCIA: No se pudo conectar a Hadoop después de $max_attempts intentos"
    echo "Continuando de todas formas..."
fi

# Configurar Spark para usar Hadoop
echo "Configurando Spark para conectarse a Hadoop..."
export SPARK_DIST_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)

# Crear directorio de logs para Spark
mkdir -p /opt/spark/logs

# Configurar Spark para usar hostname adecuado
export SPARK_PUBLIC_DNS=spark-master
export SPARK_MASTER_HOST=0.0.0.0
export SPARK_WORKER_HOST=spark-master

# Iniciar Spark Master
echo "Iniciando Spark Master..."
$SPARK_HOME/sbin/start-master.sh --host 0.0.0.0 --port 7077 --webui-port 8080

# Esperar a que el Master esté listo
sleep 5

# Iniciar Spark Worker conectándose al Master
echo "Iniciando Spark Worker..."
$SPARK_HOME/sbin/start-worker.sh spark://spark-master:7077

# Esperar a que el Worker se conecte
sleep 5

# Verificar que los servicios estén funcionando
echo "========================================="
echo "Servicios Spark en ejecución:"
echo "========================================="
jps

echo ""
echo "========================================="
echo "URLs de acceso:"
echo "========================================="
echo "Spark Master UI: http://localhost:8080"
echo "Spark Worker UI: http://localhost:8081"
echo "Jupyter Notebook: http://localhost:8888"
echo "========================================="

# Iniciar Jupyter Notebook
echo "Iniciando Jupyter Notebook..."
jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' &

# Esperar a que Jupyter se inicie
sleep 3

echo ""
echo "========================================="
echo "Contenedor Spark listo!"
echo "========================================="
echo "Puedes acceder a:"
echo "  - Jupyter: http://localhost:8888"
echo "  - Spark UI: http://localhost:8080"
echo "  - HDFS UI: http://localhost:9870"
echo "  - YARN UI: http://localhost:8088"
echo "========================================="

# Mantener el contenedor ejecutándose
tail -f /opt/spark/logs/*.out 2>/dev/null || tail -f /dev/null
