@echo off
REM Script completo para limpiar, inicializar y configurar Hadoop y Spark
REM Incluye limpieza inicial, inicialización de servicios y configuración del usuario dr.who

echo === Script completo de inicialización de Hadoop y Spark ===
echo.

REM ========================================
REM FASE 1: LIMPIEZA INICIAL
REM ========================================
echo FASE 1: Limpieza inicial del entorno...

REM 1. Detener contenedores y limpiar volúmenes
echo 1. Deteniendo contenedores y limpiando volúmenes...
docker-compose down -v

REM 2. Eliminar imagen anterior
echo 2. Eliminando imagen anterior...
docker rmi hadoopsparklocal-hadoop-spark-jupyter

REM 3. Limpiar volúmenes no utilizados
echo 3. Limpiando volúmenes no utilizados...
docker volume prune -f

REM 4. Eliminar directorio de datos de Hadoop
echo 4. Eliminando directorio de datos de Hadoop...
if exist "./hadoop-data" (
    Remove-Item -Recurse -Force ./hadoop-data
    echo Directorio hadoop-data eliminado.
) else (
    echo Directorio hadoop-data no existe, continuando...
)

REM 5. Levantar contenedores
echo 5. Levantando contenedores...
docker-compose up -d

REM Esperar a que el contenedor esté listo
echo Esperando a que el contenedor esté listo...
timeout /t 15 /nobreak >nul

echo.
echo FASE 1 COMPLETADA: Limpieza inicial finalizada.
echo.

REM ========================================
REM FASE 2: INICIALIZACIÓN DE SERVICIOS
REM ========================================
echo FASE 2: Inicialización de servicios de Hadoop y Spark...

REM 1. Formatear HDFS NameNode
echo 1. Formateando HDFS NameNode...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs namenode -format -force"

REM 2. Iniciar Hadoop NameNode
echo 2. Iniciando Hadoop NameNode...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs --daemon start namenode"

REM 3. Iniciar Hadoop DataNode
echo 3. Iniciando Hadoop DataNode...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs --daemon start datanode"

REM 4. Iniciar YARN ResourceManager
echo 4. Iniciando YARN ResourceManager...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/yarn --daemon start resourcemanager"

REM 5. Iniciar YARN NodeManager
echo 5. Iniciando YARN NodeManager...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/yarn --daemon start nodemanager"

REM 6. Crear directorio de logs de Spark
echo 6. Creando directorio de logs de Spark...
docker exec hadoop-spark-jupyter bash -c "mkdir -p /opt/spark/logs"

REM 7. Iniciar Spark Master
echo 7. Iniciando Spark Master...
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/spark/sbin/start-master.sh"

REM 8. Iniciar Spark Worker
echo 8. Iniciando Spark Worker...
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/spark/sbin/start-worker.sh spark://localhost:7077"

REM Esperar a que los servicios se inicien
echo Esperando que los servicios se inicien completamente...
timeout /t 15 /nobreak >nul

echo.
echo FASE 2 COMPLETADA: Servicios de Hadoop y Spark iniciados.
echo.

REM ========================================
REM FASE 3: CONFIGURACIÓN DEL USUARIO DR.WHO
REM ========================================
echo FASE 3: Configurando usuario dr.who para subida de archivos...

REM 9. Crear directorio para el usuario dr.who
echo 9. Creando directorio /user/dr.who en HDFS...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs dfs -mkdir -p /user/dr.who"

REM 10. Asignar permisos de propietario al usuario dr.who
echo 10. Asignando permisos de propietario a dr.who...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs dfs -chown dr.who:supergroup /user/dr.who"

REM 11. Establecer permisos 755 (lectura/escritura para propietario, lectura para otros)
echo 11. Estableciendo permisos 755 para el directorio...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs dfs -chmod 755 /user/dr.who"

REM 12. Verificar que el directorio se creó correctamente
echo 12. Verificando creación del directorio dr.who...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs dfs -ls -la /user/"

echo.
echo FASE 3 COMPLETADA: Usuario dr.who configurado correctamente.
echo.

REM ========================================
REM VERIFICACIONES FINALES
REM ========================================
echo === VERIFICACIONES FINALES ===
echo.

REM Verificar servicios Java en ejecución
echo Verificando servicios Java en ejecución...
docker exec hadoop-spark-jupyter jps

echo.
echo Verificando puertos abiertos...
docker exec hadoop-spark-jupyter bash -c "ss -tlnp | grep -E ':(8888|9870|7077|8080|8081|8088|8042)' || netstat -tlnp | grep -E ':(8888|9870|7077|8080|8081|8088|8042)' || echo 'Herramientas de red no disponibles'"

echo.
echo Verificando estructura de directorios HDFS...
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs dfs -ls /"

echo.
echo ========================================
echo INICIALIZACIÓN COMPLETA!
echo ========================================
echo.
echo Todos los servicios han sido iniciados y configurados correctamente.
echo El usuario 'dr.who' ya puede subir archivos a través de la interfaz web.
echo.
echo Puedes acceder a:
echo - Jupyter Notebook: http://localhost:8888
echo - Hadoop NameNode: http://localhost:9870
echo - YARN ResourceManager: http://localhost:8088
echo - Spark Master UI: http://localhost:8080
echo.
echo Para subir archivos como dr.who:
echo 1. Ve a http://localhost:9870
echo 2. Navega a Utilities ^> Browse the file system
echo 3. Ve al directorio /user/dr.who
echo 4. Usa el botón de subida de archivos
echo.

pause