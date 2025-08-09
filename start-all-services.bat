@echo off
REM Script para iniciar todos los servicios de Hadoop y Spark en Windows
REM Ejecutar después de: docker-compose up -d

echo === Iniciando servicios de Hadoop y Spark ===

REM 1. Formatear HDFS NameNode (solo la primera vez o después de limpieza)
echo 1. Formateando HDFS NameNode...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && /opt/hadoop/bin/hdfs namenode -format -force"

REM 2. Iniciar Hadoop NameNode
echo 2. Iniciando Hadoop NameNode...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && /opt/hadoop/bin/hdfs --daemon start namenode"

REM 3. Iniciar Hadoop DataNode
echo 3. Iniciando Hadoop DataNode...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && /opt/hadoop/bin/hdfs --daemon start datanode"

REM 4. Iniciar YARN ResourceManager
echo 4. Iniciando YARN ResourceManager...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && /opt/hadoop/bin/yarn --daemon start resourcemanager"

REM 5. Iniciar YARN NodeManager
echo 5. Iniciando YARN NodeManager...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && /opt/hadoop/bin/yarn --daemon start nodemanager"

REM 6. Crear directorio de logs de Spark
echo 6. Creando directorio de logs de Spark...
docker exec hadoop-spark-jupyter bash -c "mkdir -p /opt/spark/logs"

REM 7. Iniciar Spark Master
echo 7. Iniciando Spark Master...
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && export SPARK_CONF_DIR=/opt/spark/conf && nohup java -cp '/opt/spark/jars/*' -Xmx1g org.apache.spark.deploy.master.Master --host localhost --port 7077 --webui-port 8080 > /opt/spark/logs/spark-master.log 2>&1 &"

REM 8. Iniciar Spark Worker
echo 8. Iniciando Spark Worker...
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && export SPARK_CONF_DIR=/opt/spark/conf && nohup java -cp '/opt/spark/jars/*' -Xmx1g org.apache.spark.deploy.worker.Worker spark://localhost:7077 --host localhost --webui-port 8081 > /opt/spark/logs/spark-worker.log 2>&1 &"

REM Esperar un momento para que los servicios se inicien
echo Esperando que los servicios se inicien...
timeout /t 10 /nobreak >nul

REM Verificar servicios
echo.
echo Verificando servicios en ejecucion...
docker exec hadoop-spark-jupyter bash -c "ps aux | grep -E '(NameNode|DataNode|Master|Worker|ResourceManager|NodeManager)' | grep -v grep"

echo.
echo Verificando puertos abiertos...
docker exec hadoop-spark-jupyter bash -c "netstat -tlnp | grep -E ':(8888|9870|7077|8080|8081|8088|8042)'"

echo.
echo Todos los servicios han sido iniciados!
echo Puedes acceder a:
echo - Jupyter Notebook: http://localhost:8888
echo - Hadoop NameNode: http://localhost:9870
echo - YARN ResourceManager: http://localhost:8088
echo - Spark Master UI: http://localhost:8080

pause